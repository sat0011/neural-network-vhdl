library ieee;
use ieee.numeric_bit.all;

entity weight_g_tb is
end weight_g_tb;

architecture rtl of weight_g_tb is
	component weights_g is
		generic (
			neuron_count : integer := 0;
			addr_space : integer := 0
		);
		port (
			act_neuron : in bit_vector(addr_space-1 downto 0);
			req_wbit : in bit_vector(3 downto 0);
			w_in : in bit_vector(15 downto 0);
			clk, w_en : in bit;
			w_out : out bit
		);
	end component;
	signal act_neuron : bit_vector(1 downto 0);
	signal req_wbit : bit_vector(3 downto 0);
	signal w_in : bit_vector(15 downto 0);
	signal clk, w_en, w_out : bit;
begin
	t_weights : weights_g generic map (neuron_count => 4, addr_space => 2) port map (
		act_neuron => act_neuron, req_wbit => req_wbit,
		w_in => w_in, clk => clk, w_en => w_en,
		w_out => w_out
	);
	process
		type weight_array is array (natural range <>) of bit_vector(15 downto 0);
		constant weights : weight_array := (
			"0000000000000001",
			"0000000000000010",
			"0000000000000011",
			"0000000000000100"
		);
	begin
		-- write to weights
		w_en <= '1';
		for i in weights'range loop
			act_neuron <= bit_vector(to_unsigned(i,2));
			w_in <= weights(i);
			wait for 1 ns;
			clk <= '1';
			wait for 1 ns;
			clk <= '0';
			wait for 1 ns;
		end loop;
		w_en <= '0';
		w_in <= (others=>'0');
		wait for 1 ns;
		
		-- read weight values
		for i in weights'range loop
			act_neuron <= bit_vector(to_unsigned(i,2));
			for j in 15 downto 0 loop
				req_wbit <= bit_vector(to_unsigned(j, 4));
				clk <= '1';
				wait for 1 ns;
				clk <= '0';
				wait for 1 ns; 
				assert w_out=weights(i)(j) report "incorrect w_out" severity error;
			end loop;
		end loop;
		wait;
	end process;
end rtl;