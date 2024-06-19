entity layer is
	generic (
		neuron_count : integer := 4;
		addr_space : integer := 2
	);
	port (
		act_neuron : in bit_vector(addr_space-1 downto 0);
		prev_layer : in bit_vector(15 downto 0);
		clk : in bit;
		layer_out : out bit_vector(15 downto 0);
		
		-- neuron control signals
		wen,ren,sen,gen : in bit;
		mul_reset : in bit;
		req_wbit : in bit_vector(3 downto 0);
		write_in : in bit_vector(15 downto 0); -- for writing
		weight_write : in bit;
		nacc_en, nacc_reset : in bit
	);
end layer;

architecture rtl of layer is
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
	type neuron_out_type is array(natural range <>) of bit_vector(15 downto 0);
	signal neuron_array_out : neuron_out_type(2**addr_space-1 downto 0);
	type muxed_type is array(0 to 15) of bit_vector(addr_space-1 downto 0);
	signal muxed_array_out : muxed_type;
begin
	neuron_array:
	for i in 0 to 2**addr_space-1 generate
		l_neuron : neuron generic map (neuron_count => neuron_count, addr_space => addr_space) port map (
			neural_in => prev_layer, neural_out => neuron_array_out(i), clk => clk,
			wen => wen, sen => sen, ren => ren, gen => gen,
			mul_reset => mul_reset,
			act_neuron => act_neuron, req_wbit => req_wbit, write_in => write_in, weight_write => weight_write, nacc_en => nacc_en, nacc_reset => nacc_reset
		);
	end generate neuron_array;
	layer_mux:
	for i in 0 to 15 generate
		muxed_signal_gen:
		for j in 0 to addr_space-1 generate
			muxed_array_out(i)(j) <= neuron_array_out(j)(i);
		end generate muxed_signal_gen;
		l_mux : mux_g generic map(size => addr_space) port map (
			in0 => muxed_array_out(i), s => act_neuron,
			out0 => layer_out(i)
		);
	end generate layer_mux;
end rtl;