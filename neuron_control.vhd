entity neuron_control is
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
end neuron_control;

architecture rtl of neuron_control is
	component demux_g is
		generic (
			size : integer := 1 -- addr space
		);
		port (
			en : in bit;
			s : in bit_vector(size-1 downto 0);
			q : out bit_vector(2**size-1 downto 0)
		);
	end component;
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
	component jk_t is
		port (
			j, k, clk : in bit;
			q : out bit
		);
	end component;
	component sr_t is
		port (
			s, r, clk : in bit;
			q : out bit
		);
	end component;
	component and_g is
		generic (
			size : integer := 8
		);
		port (
			in0 : in bit_vector(size-1 downto 0);
			out0 : out bit
		);
	end component;
	-- 
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

	signal mul_en, next_w, mul_state : bit; -- mul module
	signal weight_counter_reset, weight_en : bit; -- weights
	
	type condition_type is array(natural range <>) of bit_vector(5 downto 0);
	
	signal mul_comparison : bit_vector(5 downto 0);
	signal mul_en_c : bit;
	
	signal wcr_comparison, weight_en_comparison : bit_vector(5 downto 0);
	signal wcr_c, weight_en_c : bit;
	
	signal nacc_en_comparison : bit_vector(5 downto 0);
	signal nacc_en_c : bit;
	
	signal internal_state : bit;
	signal s_reset : bit;
	signal s_reset_comparison : bit_vector(5 downto 0);
	
	signal c_step : bit_vector(5 downto 0);
	signal c_propagation : bit_vector(6 downto 1);
	
	signal right_jk_en : bit;
	signal k_reset : bit_vector(5 downto 0);
	signal i_reset : bit;
begin
	n_weights_control : weights_control generic map (addr_space => addr_space) port map (
		next_w => next_w, clk => clk, reset =>weight_counter_reset, act_neuron => act_neuron,
		req_wbit => req_wbit
	);
	n_mul_control : mul_control port map (
		clk => clk, en => mul_en, state => mul_state,
		w_en => wen, s_en => sen, r_en => ren, g_en => gen,
		reset => mul_reset, next_w => next_w
	);
	nacc_reset <= reset;
	state_sr : sr_t port map (
		s => en, r => s_reset, clk => '1',
		q => internal_state
	);
	counter:
	for i in 5 downto 0 generate
		right_jk:
		if i=0 generate
			c_jk : jk_t port map (
				j => internal_state, k => k_reset(i), clk => clk, q => c_step(i)
			);
			k_reset(i) <= internal_state or i_reset;
			c_propagation(i+1) <= internal_state and c_step(i);
		end generate right_jk;
		other_jk:
		if i>0 generate
			c_jk : jk_t port map (
				j => c_propagation(i), k => k_reset(i), clk => clk, q => c_step(i)
			);
			k_reset(i) <= c_propagation(i) or i_reset;
			c_propagation(i+1) <= c_propagation(i) and c_step(i);
		end generate other_jk;
	end generate counter;
	
	mul_comparison <= not "000000" xor c_step;
	mul_and : and_g generic map (size => 6) port map (in0 => mul_comparison, out0 => mul_en_c);
	mul_en <= mul_en_c and internal_state;
	
	wcr_comparison <= not "100100" xor c_step;
	wcr_and : and_g generic map (size => 6) port map (in0 => wcr_comparison, out0 => wcr_c);
	weight_counter_reset <= wcr_c and internal_state;
	
	weight_en_comparison <= not "100100" xor c_step;
	weight_en_and : and_g generic map (size => 6) port map (in0 => weight_en_comparison, out0 => weight_en_c);
	weight_en <= weight_en_c and internal_state;
	
	nacc_en_comparison <= not "100100" xor c_step;
	nacc_en_and : and_g generic map (size => 6) port map (in0 => nacc_en_comparison, out0 => nacc_en_c);
	nacc_en <= nacc_en_c and internal_state;
	
	s_reset_comparison <= not "100101" xor c_step;
	s_reset_and : and_g generic map (size => 6) port map (in0 => s_reset_comparison, out0 => s_reset);
	i_reset <= s_reset;
	--
	neuron_state <= internal_state;
end rtl;