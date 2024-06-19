library ieee;

use ieee.numeric_bit.all;

entity neuron_tb is
end neuron_tb;

architecture rtl of neuron_tb is
	component mul_module is
		port (
			neural_in  : in bit_vector(15 downto 0);
			clk : in bit;
			w_in : in bit;
			neural_acc_out : out bit_vector(31 downto 0);
			wen,ren,sen,gen,reset : in bit
		);	
	end component;
	component mul_control is
		port (
			clk : in bit;
			en : in bit;
			state : out bit;
			w_en, s_en, r_en, g_en : out bit;
			reset : out bit;
			next_w : out bit
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
	component neural_acc is
		port (
			clk, en : in bit;
			reset : in bit;
			mul_acc : in bit_vector(15 downto 0);
			neural_sum : out bit_vector(15 downto 0)
		);
	end component;
	-- mul module
	signal clk : bit;
	signal neural_in : bit_vector(15 downto 0);
	signal mul_win, ren,sen,wen,gen, reset : bit;
	signal mul_acc_out : bit_vector(31 downto 0);
	-- mul control
	signal mul_en : bit;
	signal mul_state, next_w : bit;
	-- weights
	signal act_neuron : bit_vector(1 downto 0); -- 4 neurons
	signal req_wbit : bit_vector(3 downto 0);
	signal weight_write : bit_vector(15 downto 0);
	signal weight_en : bit;
	signal weight_out : bit;
	-- weights control
	signal weight_counter_reset : bit;
	-- neural accumulator
	signal nacc_reset : bit;
	signal neural_sum : bit_vector(15 downto 0);
	signal nacc_en : bit;
begin
	w_mul_module : mul_module port map (
		neural_in => neural_in,
		clk => clk, 
		w_in => mul_win,
		neural_acc_out => mul_acc_out,
		wen => wen, ren=>ren, sen=>sen, gen=>gen,
		reset=>reset
	);
	w_mul_control : mul_control port map (
		clk => clk, en => mul_en,
		state => mul_state, 
		w_en => wen, s_en => sen, r_en => ren, g_en => gen,
		reset => reset, next_w => next_w
	);
	w_weights : weights_g generic map (neuron_count => 4, addr_space => 2) port map (
		act_neuron => act_neuron,
		req_wbit => req_wbit,
		w_in => weight_write, 
		clk => clk, w_en => weight_en,
		w_out => mul_win
	);
	w_weights_control : weights_control generic map (addr_space => 2) port map (
		next_w => next_w, clk => clk, reset => weight_counter_reset,
		act_neuron => act_neuron,
		req_wbit => req_wbit
	);
	w_neural_acc : neural_acc port map (
		clk => clk, en => nacc_en,
		reset => nacc_reset,
		mul_acc => mul_acc_out(31 downto 16),
		neural_sum => neural_sum
	);
	process
		type weights_type is array(natural range <>) of bit_vector(15 downto 0);
		constant weights : weights_type := (
			"0111111111111111",
			"1111111111111111",
			"0000000000000000",
			"0000000000000000"
		);
	begin
		-- write weight values
		for i in weights'range loop
			act_neuron <= bit_vector(to_unsigned(i,2));
			weight_write <= weights(i);
			weight_en <= '1';
			wait for 1 ns;
			clk <= '1';
			wait for 1 ns;
			clk <= '0';
			wait for 1 ns;
		end loop;
		weight_en <= '0';
		-- test proper
		neural_in <= "0000000000001101";
		nacc_reset <= '1';
		nacc_en <= '1';
		wait for 1 ns;
		clk <= '0';
		nacc_reset <= '0';
		nacc_en <= '0';
		wait for 1 ns;
		clk <= '1';
		wait for 1 ns;
		for i in weights'range loop
			act_neuron <= bit_vector(to_unsigned(i,2));
			mul_en <= '1';
			wait for 1 ns;
			clk <= '1';
			wait for 1 ns;
			clk <= '0';
			mul_en <= '0';
			wait for 1 ns;
			for j in 35 downto 0 loop
				clk <= '1';
				wait for 1 ns;
				clk <= '0';
				wait for 1 ns;
			end loop;
			weight_counter_reset <= '1';
			weight_en <= '1';
			nacc_en <= '1';
			wait for 1 ns;
			clk <= '1';
			wait for 1 ns;
			weight_counter_reset <= '0';
			weight_en <= '0';
			nacc_en <= '0';
			clk <= '0';
			wait for 1 ns;
		end loop;
	wait;
	end process;
end rtl;
