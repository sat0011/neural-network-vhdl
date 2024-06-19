entity neuron is
	generic (
		neuron_count: integer := 4; -- from prev. layer
		addr_space : integer := 2
	);
	port (
		neural_in : in bit_vector(15 downto 0); -- from prev. layer
		neural_out : out bit_vector(15 downto 0);
		clk : in bit;
		-- control signal hell
		
		--mul
		wen, ren, sen, gen : in bit;
		mul_reset : in bit;
		--weights
		act_neuron : in bit_vector(addr_space-1 downto 0);
		req_wbit : in bit_vector(3 downto 0);
		write_in : in bit_vector(15 downto 0); -- for writing
		weight_write : in bit;
		--acc
		nacc_en, nacc_reset : in bit
	);
end neuron;

architecture rtl of neuron is
	component mul_module is
		port (
			neural_in  : in bit_vector(15 downto 0);
			clk : in bit;
			w_in : in bit;
			neural_acc_out : out bit_vector(31 downto 0);
			wen,ren,sen,gen,reset : in bit
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
	component neural_acc is
		port (
			clk, en : in bit;
			reset : in bit;
			mul_acc : in bit_vector(15 downto 0);
			neural_sum : out bit_vector(15 downto 0)
		);
	end component;
	
	signal weights_bit : bit;
	signal mul_acc_out : bit_vector(31 downto 0);
begin
	n_mul_module : mul_module port map (
		neural_in => neural_in, 
		clk => clk,
		w_in => weights_bit, 
		neural_acc_out => mul_acc_out,
		wen => wen, ren => ren, sen => sen, gen => gen,
		reset => mul_reset
	);
	n_weights : weights_g generic map (neuron_count => neuron_count, addr_space => addr_space) port map (
		act_neuron => act_neuron,
		req_wbit => req_wbit,
		w_in => write_in,
		clk => clk, w_en => weight_write,
		w_out => weights_bit
	);
	n_acc : neural_acc port map (
		clk => clk, en => nacc_en,
		reset => nacc_reset, 
		mul_acc => mul_acc_out(31 downto 16),
		neural_sum => neural_out
	);
end rtl;
