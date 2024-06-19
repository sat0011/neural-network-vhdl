library ieee;
use ieee.numeric_bit.all;

entity weights_g is
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
end weights_g;

architecture rtl of weights_g is
	component d_t is
		port (
			d, clk : in bit;
			q : out bit
		);
	end component;
	component dt_fall is
		port (
			d, clk : in bit;
			q : out bit
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
	component demux_g is
		generic (
			size : integer := 1
		);
		port (
			en : in bit;
			s : in bit_vector(size-1 downto 0);
			q : out bit_vector(2**size-1 downto 0)
		);
	end component;
	
	type data_array is array (neuron_count-1 downto 0) of bit_vector(15 downto 0);
	signal mux_weight : bit_vector(2**addr_space-1 downto 0);
	
	signal w_addr : bit_vector(2**addr_space-1 downto 0);
	signal d_out : data_array;
	signal d_en	: bit_vector(neuron_count-1 downto 0);
	
begin

	write_decoder : demux_g generic map (size => addr_space) port map (
		en => w_en, s => act_neuron, q=>w_addr
	);
	
	--weight_array:
	--for i in neuron_count-1 downto 0 generate
	--	d_en(i) <= clk and w_addr(i);
	--	weight_bit:
	--	for j in 15 downto 0 generate
	--		w_dt : dt_fall port map (d => w_in(j), clk => d_en(i), q => d_out(i)(j));
	--	end generate weight_bit;
	--end generate weight_array;
	
	-- writing and data array
	weight_array:
	for i in 2**addr_space-1 downto 0 generate
		d_en(i) <= w_addr(i) and clk;
		weight_bit:
		for j in 15 downto 0 generate
			w_dt : d_t port map (
				d => w_in(j), clk => d_en(i), q => d_out(i)(15-j)
			);
		end generate weight_bit;
	end generate weight_array;
	
	-- multiplexer
	weight_mux:
	for i in neuron_count-1 downto 0 generate
		w_mux : mux_g generic map(size => 4) port map (
			in0 => d_out(i), s => req_wbit,
			out0 => mux_weight(i)
		);
	end generate weight_mux;
	neuron_mux : mux_g generic map (size => addr_space) port map (
		in0 => mux_weight, s => act_neuron,
		out0 => w_out
	);
end rtl;