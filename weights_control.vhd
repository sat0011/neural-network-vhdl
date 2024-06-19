entity weights_control is
	generic (
		addr_space : integer := 2
	);
	port (
		next_w, clk, reset : in bit;
		act_neuron : in bit_vector(addr_space-1 downto 0);
		req_wbit : out bit_vector(3 downto 0)
	);
end weights_control;

architecture rtl of weights_control is
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
	component jk_t is
		port (
			j, k, clk : in bit;
			q : out bit
		);
	end component;
	
	signal c_step : bit_vector(3 downto 0);
	signal c_propagation : bit_vector(4 downto 1);
	
	signal right_jk_en : bit;
	signal k_reset : bit_vector(3 downto 0);
begin
	right_jk_en <= next_w and not reset and (not c_step(0) or not c_step(1) or not c_step(2) or not c_step(3));
	counter:
	for i in 3 downto 0 generate
		right_jk:
		if i=0 generate
			c_jk : jk_t port map (
				j => right_jk_en, k => k_reset(i), clk => clk, q => c_step(i)
			);
			k_reset(i) <= right_jk_en or reset;
			c_propagation(i+1) <= c_step(i) and right_jk_en;
		end generate right_jk;
		other_jk:
		if i>0 generate
			c_jk : jk_t port map (
				j => c_propagation(i), k => k_reset(i), clk => clk, q => c_step(i)
			);
			k_reset(i) <= c_propagation(i) or reset;
			c_propagation(i+1) <= c_step(i) and c_propagation(i);
		end generate other_jk;
	end generate;
	req_wbit <= c_step;
end rtl;