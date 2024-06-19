entity jk_t is
	port (
		j, k, clk : in bit;
		q : out bit
	);
end jk_t;

architecture rtl of jk_t is
	component sr_t is
		port (
			s, r, clk : in bit;
			q : out bit
		);
	end component;
	signal fall_clk : bit;
	signal s_slave, r_slave : bit;
	signal s_master, r_master: bit;
	signal q_master : bit;
begin
	fall_clk <= not clk;
	slave_sr : sr_t port map(clk => clk, s => s_slave, r => r_slave, q => s_master);
	
	r_master <= not s_master;
	master_sr : sr_t port map(clk => fall_clk, s => s_master, r => r_master, q => q_master);
	s_slave <= not q_master and j;
	r_slave <= q_master and k;
	q <= q_master;
end rtl;

