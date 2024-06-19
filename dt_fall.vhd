entity dt_fall is
	port (
		d, clk : in bit;
		q : out bit
	);
end dt_fall;

architecture rtl of dt_fall is
	component d_t is
		port (
			d, clk : in bit;
			q : out bit
		);
	end component;
	signal m_out : bit;
	signal s_clk : bit;
begin
	s_clk <= not clk;
	m_dt : d_t port map (
		d => d, clk => clk, q => m_out
	);
	s_dt : d_t port map (
		d => m_out, clk => s_clk, q => q
	);
end rtl;