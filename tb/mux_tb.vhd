entity mux_tb is
end mux_tb;

architecture rtl of mux_tb is

	component mux is
		port (
			a, b, s : in bit;
			q : out bit
		);
	end component;

	signal a, b, s: bit;
	signal q : bit;
begin
	
	tb_mux : mux port map (
		a => a, b => b, s => s, q => q
	);

	process
		type pattern_type is record 
			a, b, s : bit;
			q : bit;
		end record;
		
		type pattern_array is array (natural range <>) of pattern_type;
		constant patterns : pattern_array := (
		 (a => '0', b =>'0', s => '0', q=>'0'),
		 (a => '1', b =>'0', s => '0', q=>'1'),
		 (a => '0', b =>'1', s => '1', q=>'1'),
		 (a => '0', b =>'1', s => '0', q=>'0')
		);
		begin
			for i in patterns'range loop
				a <= patterns(i).a;
				b <= patterns(i).b;
				s <= patterns(i).s;
				wait for 1 ns;
				assert q = patterns(i).q report "output error" severity error;
			end loop;
			wait;
	end process;
	
end rtl;