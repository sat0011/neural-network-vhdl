entity neuron_control_tb is
end neuron_control_tb;

architecture rtl of neuron_control_tb is
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
			write_in : out bit_vector(15 downto 0);
			weight_write : out bit;
			
			nacc_en, nacc_reset : out bit -- acc
		);
	end component;
	--signal clk, en, reset, nacc_reset, nacc_en, mul_en, weight_counter_reset, weight_en, neuron_state : bit;
	signal act_neuron : bit_vector(1 downto 0);
	signal clk, en, reset, neuron_state : bit;
	signal wen, ren, sen, gen, mul_reset : bit;
	signal req_wbit : bit_vector(3 downto 0);
	signal write_in : bit_vector(15 downto 0);
	signal weight_write : bit;
	signal nacc_en, nacc_reset : bit;
begin
	--w_neuron_control : neuron_control port map (
	--	clk => clk, en => en, reset => reset, nacc_reset => nacc_reset, nacc_en => nacc_en, mul_en => mul_en,
	--	weight_counter_reset => weight_counter_reset, weight_en => weight_en, neuron_state => neuron_state
	--);
	w_neuron_control : neuron_control generic map (addr_space => 2) port map (
		act_neuron => act_neuron,
		clk => clk, en => en,
		reset => reset,
		neuron_state => neuron_state,
		wen => wen, ren => ren, sen => sen, gen => gen, mul_reset => mul_reset,
		
		req_wbit => req_wbit, write_in => write_in, weight_write => weight_write,
		
		nacc_en => nacc_en, nacc_reset => nacc_reset
	);
	process begin
		for j in 0 to 3 loop
			en <= '1';
			wait for 1 ns;
			clk <= '1';
			wait for 1 ns;
			clk <= '0';
			en <= '0';
			wait for 1 ns;
			for i in 0 to 63 loop
				clk <= '1';
				wait for 1 ns;
				clk <= '0';
				wait for 1 ns;
			end loop;
		end loop;
		wait;
	end process;	
end rtl;