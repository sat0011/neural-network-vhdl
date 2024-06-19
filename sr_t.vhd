entity sr_t is 
port (
 s, r, clk : in bit;
 q : out bit
);
end sr_t;

architecture rlt of sr_t is
	component d_t is
		port (
			d, clk : in bit;
			q : out bit
		);
	end component;
	signal set_state : bit;
	signal real_clk : bit;
begin

	set_state <= s or not r;
	real_clk <= (s or r) and clk;
	work_dt : d_t port map (q => q, d => set_state, clk => real_clk);
end rlt;