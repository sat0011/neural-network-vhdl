library ieee;
use ieee.numeric_bit.all;

entity neuron_control_tbr is
end neuron_control_tbr;

architecture rtl of neuron_control_tbr is
	constant addr_space : integer := 4;
	constant neuron_count : integer := 16;
	
	signal neuron_state : bit;
	
	signal wen,ren,sen,gen,mul_reset : bit;
	signal act_neuron : bit_vector(addr_space-1 downto 0);
	signal neural_in, neural_out : bit_vector(15 downto 0);
	signal clk, neuron_en : bit;
	signal reset : bit;
	signal req_wbit : bit_vector(3 downto 0);
	signal weight_write_in : bit_vector(15 downto 0);
	signal weight_write_en : bit;
	
	signal nacc_en, nacc_reset : bit;
	
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
begin
	tb_neuron : neuron generic map (neuron_count => neuron_count, addr_space => addr_space) port map (
		act_neuron => act_neuron, neural_in => neural_in, neural_out => neural_out, clk => clk, weight_write => weight_write_en,
		wen => wen, ren => ren, sen => sen, gen => gen,
		mul_reset => mul_reset, req_wbit => req_wbit, write_in => weight_write_in, nacc_en => nacc_en, nacc_reset => nacc_reset
	);
	tb_control : neuron_control generic map (addr_space => addr_space) port map (
		act_neuron => act_neuron, clk => clk, en => neuron_en, reset => reset, neuron_state => neuron_state,
		wen => wen, ren => ren, sen => sen, gen => gen, mul_reset => mul_reset,
		req_wbit => req_wbit, nacc_en =>  nacc_en, nacc_reset => nacc_reset
	);
	process
		type weights_type is array(natural range <>) of bit_vector(15 downto 0);
		constant weights : weights_type := (
			"1111111111111111",
			"1111111111111100",
			"1111111111110011",
			"1111111111110000",
			"0111111111111111",
			"0111111111111100",
			"0111111111110011",
			"0111111111110000",
			"0011111111111111",
			"0011111111111100",
			"0011111111110011",
			"0011111111110000",
			"0001111111111111",
			"0001111111111100",
			"0001111111110011",
			"0001111111110000"
		);
	begin
		for i in weights'range loop
			act_neuron <= bit_vector(to_unsigned(i,4));
			weight_write_in <= weights(i);
			weight_write_en <= '1';
			wait for 1 ns;
			clk <= '1';
			wait for 1 ns;
			clk <= '0';
			wait for 1 ns;
		end loop;
		weight_write_en <= '0';
		
		neural_in <= "1111111111111111";
		
		for i in weights'range loop
			act_neuron <= bit_vector(to_unsigned(i,4));
			neuron_en <= '1';
			wait for 1 ns;
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
		end loop;
		
		wait;
	end process;
end rtl;