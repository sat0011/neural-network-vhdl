entity test is
end test;

architecture rtl of test is

	component d_t is port (
		d, clk : in bit;
		q : out bit
	);
	end component;
	signal d1, d2, clk : bit;
	signal q1, q2 : bit;
begin
	dt1 : d_t port map (
		d => d1, clk => clk, q => q1
	);
	d2 <= q1;
	dt2 : d_t port map (
		d => d2, clk => clk, q => q2
	);
	process
	begin
		d1 <= '1';
		clk <= '1';
		wait for 1 ns;
		d1 <= '0';
		clk <= '0';
		wait for 1 ns;
		clk <= '1';
		wait for 1 ns;
		wait;
	end process;
end rtl;