entity d_t_tb is
end d_t_tb;

architecture rtl of d_t_tb is
	component d_t is
		port (
			d, clk : in bit;
			q : out bit
		);
	end component;
	signal d, clk, q : bit;
begin
	t_d_t : d_t port map (
		d => d, clk => clk,
		q => q
	);
	process
		type pattern_type is record
			d, clk : bit;
			q : bit;
		end record;	
		type pattern_array is array (natural range <>) of pattern_type;
		constant patterns : pattern_array := (
		 (d => '0', clk => '0', q => '0'),
		 (d => '1', clk => '0', q => '0'),
		 (d => '1', clk => '1', q => '1'),
		 (d => '0', clk => '0', q => '1'),
		 (d => '0', clk => '1', q => '0'),
		 (d => '0', clk => '0', q => '0'),
		 (d => '0', clk => '1', q => '0'),
		 (d => '1', clk => '0', q => '0'),
		 (d => '0', clk => '0', q => '0')
		);
	begin
		for i in patterns'range loop
			d <= patterns(i).d;
			clk <= patterns(i).clk;
			wait for 1 ns;
			assert q = patterns(i).q report "out error" severity error;
		end loop;
		wait;
	end process;
end rtl;