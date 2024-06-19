library ieee;
use ieee.numeric_bit.all;

entity weights_control_tb is
end weights_control_tb;

architecture rtl of weights_control_tb is
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
	
	component weights_control is
		generic (
			addr_space : integer := 2
		);
		port (
			next_w, clk, reset : in bit;
			act_neuron : in bit_vector(addr_space-1 downto 0);
			req_wbit : out bit_vector(3 downto 0)
		);
	end component;
	component weights_g is
		generic (
			neuron_count : integer := 0;
			addr_space : integer := 0
		);
		port (
			act_neuron : in bit_vector(addr_space-1 downto 0); -- addr space
			req_wbit : in bit_vector(3 downto 0); -- no. of req bit
			w_in : in bit_vector(15 downto 0);
			clk, w_en : in bit;
			w_out : out bit
		);
	end component;
	signal clk, next_w, reset : bit;
	signal act_neuron : bit_vector(1 downto 0);
	signal w_out : bit;
	
	signal req_wbit : bit_vector(3 downto 0);
	
	signal w_in : bit_vector(15 downto 0);
	signal w_en : bit;
begin
	w_weight_control : weights_control generic map (addr_space => 2) port map (
		next_w => next_w, clk => clk, reset => reset,
		act_neuron => act_neuron,
		req_wbit => req_wbit
	);
	w_weights : weights_g generic map (addr_space => 2, neuron_count => 4) port map (
		act_neuron => act_neuron,
		req_wbit => req_wbit,
		w_in => w_in, w_en => w_en, clk => clk,
		w_out => w_out
	);
	process 
		type weight_type is array(natural range <>) of bit_vector (15 downto 0);
		constant weights : weight_type := (
			("0010000000000001"),
			("0010000000000010"),
			("0010000000000011"),
			("0010000000000100")
		);
	begin
		-- write weights
		w_en <= '1';
		for i in 0 to 3 loop
			act_neuron <= bit_vector(to_unsigned(i,2));
			w_in <= weights(i);
			wait for 1 ns;
			clk <= '1';
			wait for 1 ns;
			clk <= '0';
			wait for 1 ns;
		end loop;
		w_en <= '0';
		wait for 1 ns;
		
		--proper test
		for i in 0 to 3 loop
			act_neuron <= bit_vector(to_unsigned(i,2));
			reset <= '1';
			wait for 1 ns;
			clk <= '1';
			wait for 1 ns;
			clk <= '0';
			wait for 1 ns;
			reset <= '0';
			for j in 0 to 15 loop
				next_w <= '1';
				wait for 1 ns;
				clk <= '1';
				wait for 1 ns;
				clk <= '0';
				wait for 1 ns;
				-- assert w_out=weights(i)(j) report "weight bit output issue, bit: " & integer'image(j) severity error;
			end loop;
			
		end loop;
		
		wait;
	end process;
end rtl;