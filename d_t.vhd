entity d_t is
	port (
		d, clk : in bit;
		q : out bit
	);
end d_t;

architecture rtl of d_t is 
	component mux is
		port (
			a, b, s : in bit;
			q : out bit
		);
	end component;
	signal data : bit;
begin
	q <= data;
	d_mux : mux port map (
		a => data, b => d, s => clk,
		q => data
	);
end rtl;