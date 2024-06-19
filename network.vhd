library ieee;

use std.textio.all;
use ieee.numeric_bit.all;

entity network is 
end network;

architecture rtl of network is
	
	constant addr_space : integer := 4;
	constant neuron_count : integer := 16;
	
	signal neuron_state : bit;
	signal act_neuron : bit_vector(addr_space-1 downto 0);
	
	signal wen,ren,sen,gen,mul_reset : bit;
	signal neural_in, neural_out : bit_vector(15 downto 0);
	signal clk : bit;
	signal neuron_en : bit_vector(0 to 3);
	signal reset : bit;
	signal req_wbit : bit_vector(3 downto 0);
	signal weight_write_in : bit_vector(15 downto 0);
	signal weight_write_en : bit;
	
	signal nacc_en, nacc_reset : bit;
	
	component mux_g is
		generic (
			size : integer := 1
		);
		port (
			in0 : in bit_vector(2**size-1 downto 0);
			s : in bit_vector(size-1 downto 0);
			out0 : out bit
		);
	end component;
	
	component neuron_control is
		generic (
			addr_space : integer := 2
		);
		port (
			act_neuron : in bit_vector(addr_space-1 downto 0);
			clk, en : in bit;
			reset : in bit; -- only ever needed on repeat activations
			neuron_state : out bit;
			-- control signal hell
			wen, ren, sen, gen, mul_reset : out bit; -- mul
			
			req_wbit : out bit_vector(3 downto 0); -- weights
			--write_in : out bit_vector(15 downto 0);
			--weight_write : out bit;
			
			nacc_en, nacc_reset : out bit -- acc
		);
	end component;
	component neuron is
		generic (
			neuron_count: integer := 4;
			addr_space : integer := 2
		);
		port (
			act_neuron : in bit_vector(addr_space-1 downto 0); -- req for both weights and layer mux
			neural_in : in bit_vector(15 downto 0); -- from prev. layer
			neural_out : out bit_vector(15 downto 0);
			clk : in bit;
			-- control signal hell
			
			--mul
			wen, ren, sen, gen : in bit;
			mul_reset : in bit;
			--weights
			req_wbit : in bit_vector(3 downto 0);
			write_in : in bit_vector(15 downto 0); -- for writing
			weight_write : in bit;
			--acc
			nacc_en, nacc_reset : in bit
		);
	end component;
	
	function bitvec_to_str(inp: bit_vector) return string is
		variable temp: string(inp'left+1 downto 1);
	begin
		for i in inp'reverse_range loop
			if (inp(i) = '1') then
				temp(i+1) := '1';
			else temp(i+1) := '0';
			end if;
			--temp(i) := '1' when inp(i)='1' else '0';
		end loop;
		return temp;
	end function bitvec_to_str;
	
	type in_array_type is array (15 downto 0) of bit_vector(15 downto 0);
	signal in_array : in_array_type;
	type pre_muxed_type is array(15 downto 0) of bit_vector(15 downto 0);
	signal pre_muxed_in : pre_muxed_type;
	signal in_mux : bit_vector(15 downto 0);
	
	type inl_out_type is array(15 downto 0) of bit_vector(15 downto 0);
	signal inl_raw : inl_out_type;
	signal inl_prmx : inl_out_type;
	signal inl_out : bit_vector(15 downto 0);
	
	-- layers
	-- input layer
	signal input_mux_select : bit_vector(3 downto 0);
	signal act_neuron_input : bit_vector(3 downto 0);
	signal inl_write_en : bit_vector(15 downto 0);
	signal inl_write_in : bit_vector(15 downto 0);
	-- hidden 1
	signal hdn1_mux_select : bit_vector(3 downto 0);
	signal hdn1_write_en : bit_vector(15 downto 0);
	signal hdn1_write_in : bit_vector(15 downto 0);
	signal hdn1_raw : inl_out_type;
	signal hdn1_prmx : inl_out_type;
	signal hdn1_out : bit_vector(15 downto 0);
	-- hidden 2
	signal hdn2_mux_select : bit_vector(3 downto 0);
	signal hdn2_write_en : bit_vector(15 downto 0);
	signal hdn2_write_in : bit_vector(15 downto 0);
	signal hdn2_raw : inl_out_type;
	signal hdn2_prmx : inl_out_type;
	signal hdn2_out : bit_vector(15 downto 0);
	-- out
	signal out_mux_select : bit_vector(3 downto 0);
	signal out_write_en : bit_vector(9 downto 0);
	signal out_write_in : bit_vector(15 downto 0);
	type out_type is array (9 downto 0) of bit_vector(15 downto 0);
	signal out_raw : out_type;
	
begin
	input_mux:
	for i in 15 downto 0 generate
		pre_input_mux:
		for j in 15 downto 0 generate
			pre_muxed_in(i)(j) <= in_array(j)(i);
		end generate pre_input_mux;
		input_mux_e : mux_g generic map (size => 4) port map (
			in0 => pre_muxed_in(i), s => input_mux_select,
			out0 => in_mux(i)
		);
	end generate input_mux;
	
	input_layer_g:
	for i in 15 downto 0 generate
		inl_neuron : neuron generic map (neuron_count => 16, addr_space => 4) port map (
			act_neuron => input_mux_select, neural_in => in_mux, neural_out => inl_raw(i),
			wen => wen, ren => ren, sen => sen, gen => gen,
			clk => clk,mul_reset => mul_reset, req_wbit => req_wbit, nacc_en => nacc_en, nacc_reset => nacc_reset,
			write_in => inl_write_in,  weight_write => inl_write_en(i)
		);
	end generate input_layer_g;
	--input layer mux
	inl_mux_g:
	for i in 15 downto 0 generate
		inl_prmx_g:
		for j in 15 downto 0 generate
			inl_prmx(i)(j) <= inl_raw(j)(i);
		end generate inl_prmx_g;
		inl_mux : mux_g generic map (size => 4) port map (
			in0 => inl_prmx(i), s => hdn1_mux_select,
			out0 => inl_out(i)
		);
	end generate inl_mux_g;
	
	hidden_layer1_g:	
	for i in 15 downto 0 generate
		hdn1_neuron : neuron generic map (neuron_count => 16, addr_space => 4) port map (
			act_neuron => hdn1_mux_select, neural_in => inl_out, neural_out => hdn1_raw(i),
			wen => wen, ren => ren, sen => sen, gen => gen,
			clk => clk,mul_reset => mul_reset, req_wbit => req_wbit, nacc_en => nacc_en, nacc_reset => nacc_reset,
			write_in => hdn1_write_in,  weight_write => hdn1_write_en(i)
		);
	end generate hidden_layer1_g;
	-- hidden layer 1 mux
	hdn1_mux_g:
	for i in 15 downto 0 generate
		hdn1_prmx_g:
		for j in 15 downto 0 generate
			hdn1_prmx(i)(j) <= hdn1_raw(j)(i);
		end generate hdn1_prmx_g;
		hdn1_mux : mux_g generic map (size => 4) port map (
			in0 => hdn1_prmx(i), s => hdn2_mux_select,
			out0 => hdn1_out(i)
		);
	end generate hdn1_mux_g;
	
	hidden_layer2_g:	
	for i in 15 downto 0 generate
		hdn2_neuron : neuron generic map (neuron_count => 16, addr_space => 4) port map (
			act_neuron => hdn2_mux_select, neural_in => hdn1_out, neural_out => hdn2_raw(i),
			wen => wen, ren => ren, sen => sen, gen => gen,
			clk => clk,mul_reset => mul_reset, req_wbit => req_wbit, nacc_en => nacc_en, nacc_reset => nacc_reset,
			write_in => hdn2_write_in,  weight_write => hdn2_write_en(i)
		);
	end generate hidden_layer2_g;
	-- hidden layer 2 mux
	hdn2_mux_g:
	for i in 15 downto 0 generate
		hdn2_prmx_g:
		for j in 15 downto 0 generate
			hdn2_prmx(i)(j) <= hdn2_raw(j)(i);
		end generate hdn2_prmx_g;
		hdn2_mux : mux_g generic map (size => 4) port map (
			in0 => hdn2_prmx(i), s => out_mux_select,
			out0 => hdn2_out(i)
		);
	end generate hdn2_mux_g;
	
	out_layer_g:
	for i in 9 downto 0 generate
		out_neuron : neuron generic map (neuron_count => 16, addr_space => 4) port map (
			act_neuron => out_mux_select, neural_in => hdn2_out, neural_out => out_raw(i),
			wen => wen, ren => ren, sen => sen, gen => gen,
			clk => clk,mul_reset => mul_reset, req_wbit => req_wbit, nacc_en => nacc_en, nacc_reset => nacc_reset,
			write_in => out_write_in,  weight_write => out_write_en(i)
		);
	end generate out_layer_g;
	
	-- neural control
	w_control : neuron_control generic map (addr_space => addr_space) port map (
		act_neuron => act_neuron, clk => clk, en => neuron_en, reset => reset, neuron_state => neuron_state,
		wen => wen, ren => ren, sen => sen, gen => gen, mul_reset => mul_reset,
		req_wbit => req_wbit, nacc_en =>  nacc_en, nacc_reset => nacc_reset
	);
	
	--set up complete
	process
		file input_file : text;
		file out_file : text;
		
		variable input_line : line;
		variable input_str : string (16 downto 1);
		variable input_vec : bit_vector(15 downto 0);
		
		variable output_vec : bit_vector(15 downto 0);
		variable output_str : string (16 downto 1);
		--type input_weights_type is array(255 downto 0) of bit_vector(15 downto 0);
		--variable input_weights : input_weights_type;
	begin
	
		-- input layer init
		file_open(input_file, "input_weights.txt", READ_MODE);
		for i in 1 downto 0 loop
		inl_write_en <= "0000000000000000";
			for j in 16 downto 0 loop
				readline(input_file, input_line);
				read(input_line, input_vec);
				--assert false report "input: " & bitvec_to_str(input_vec) severity note;
				inl_write_in <= input_vec;
				input_mux_select <= bit_vector(to_unsigned(j,4));
				inl_write_en(i) <= '1';
				wait for 1 ns;
				clk <= '1';
				wait for 1 ns;
				clk <= '0';
				wait for 1 ns;
			end loop;
		end loop;
		inl_write_en <= "0000000000000000";
		wait for 1 ns;
		-- hidden layer 1 init
		file_close(input_file);
		file_open(input_file, "hidden1_weights.txt", READ_MODE);
		for i in 15 downto 0 loop
		hdn1_write_en <= "0000000000000000";
			for j in 15 downto 0 loop
				readline(input_file, input_line);
				read(input_line, input_vec);
				--assert false report "input: " & bitvec_to_str(input_vec) severity note;
				hdn1_write_in <= input_vec;
				hdn1_mux_select <= bit_vector(to_unsigned(j,4));
				hdn1_write_en(i) <= '1';
				wait for 1 ns;
				clk <= '1';
				wait for 1 ns;
				clk <= '0';
				wait for 1 ns;
			end loop;
		end loop;
		hdn1_write_en <= "0000000000000000";
		wait for 1 ns;
		-- hidden layer 2 init
		file_close(input_file);
		file_open(input_file, "hidden2_weights.txt", READ_MODE);
		for i in 15 downto 0 loop
		hdn2_write_en <= "0000000000000000";
			for j in 15 downto 0 loop
				readline(input_file, input_line);
				read(input_line, input_vec);
				--assert false report "input: " & bitvec_to_str(input_vec) severity note;
				hdn2_write_in <= input_vec;
				hdn2_mux_select <= bit_vector(to_unsigned(j,4));
				hdn2_write_en(i) <= '1';
				wait for 1 ns;
				clk <= '1';
				wait for 1 ns;
				clk <= '0';
				wait for 1 ns;
			end loop;
		end loop;
		hdn2_write_en <= "0000000000000000";
		wait for 1 ns;
		-- out layer init
		file_close(input_file);
		file_open(input_file, "out_weights.txt", READ_MODE);
		for i in 9 downto 0 loop
		out_write_en <= "0000000000";
			for j in 15 downto 0 loop
				readline(input_file, input_line);
				read(input_line, input_vec);
				--assert false report "input: " & bitvec_to_str(input_vec) severity note;
				out_write_in <= input_vec;
				out_mux_select <= bit_vector(to_unsigned(j,4));
				out_write_en(i) <= '1';
				wait for 1 ns;
				clk <= '1';
				wait for 1 ns;
				clk <= '0';
				wait for 1 ns;
			end loop;
		end loop;
		out_write_en <= "0000000000";
		wait for 1 ns;
		-- init end;
		-- //////////////////////////////
		--/////////
		
		-- setting up neural input
		file_close(input_file);
		file_open(input_file, "input.txt", READ_MODE);
		for i in 0 to 15 loop
			readline(input_file, input_line);
			read(input_line, input_vec);
			in_array(i) <= input_vec;
		end loop;
		wait for 1 ns;
		
		-- input calc;
		for i in input_mux_select'range loop
			input_mux_select <= bit_vector(to_unsigned(i,4));
			neuron_en <= '1';
			clk <= '1';
			wait for 1 ns;
			neuron_en <= '0';
			clk <= '1';
			wait for 1 ns;
			for j in 35 downto 0 loop
				clk <= '1';
				wait for 1 ns;
				clk <= '0';
				wait for 1 ns;
			end loop;
			wait for 1 ns;
		end loop;
		-- hidden 1 calc
		for i in hdn1_mux_select'range loop
			hdn1_mux_select <= bit_vector(to_unsigned(i,4));
			neuron_en <= '1';
			clk <= '1';
			wait for 1 ns;
			neuron_en <= '0';
			clk <= '1';
			wait for 1 ns;
			for j in 35 downto 0 loop
				clk <= '1';
				wait for 1 ns;
				clk <= '0';
				wait for 1 ns;
			end loop;
			wait for 1 ns;
		end loop;
		-- hidden 2 calc
		for i in hdn2_mux_select'range loop
			hdn2_mux_select<= bit_vector(to_unsigned(i,4));
			neuron_en <= '1';
			clk <= '1';
			wait for 1 ns;
			neuron_en <= '0';
			clk <= '1';
			wait for 1 ns;
			for j in 35 downto 0 loop
				clk <= '1';
				wait for 1 ns;
				clk <= '0';
				wait for 1 ns;
			end loop;
			wait for 1 ns;
		end loop;
		-- out calc
		for i in out_mux_select'range loop
			out_mux_select <= bit_vector(to_unsigned(i,4));
			neuron_en <= '1';
			clk <= '1';
			wait for 1 ns;
			neuron_en <= '0';
			clk <= '1';
			wait for 1 ns;
			for j in 35 downto 0 loop
				clk <= '1';
				wait for 1 ns;
				clk <= '0';
				wait for 1 ns;
			end loop;
			wait for 1 ns;
		end loop;
		for i in out_raw'range loop
			assert false report "out: " & bitvec_to_str(out_raw(i)) severity note;
		end loop;
		wait;
	end process;
	
end rtl;