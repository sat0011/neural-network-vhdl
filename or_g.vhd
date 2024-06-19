entity or_g is
	generic (
		size : integer := 8
	);
	port (
		in0 : in bit_vector(size-1 downto 0);
		out0 : out bit
	);
end or_g;

architecture rtl of or_g is
	signal or_ladder : bit_vector(size-1 downto 0);
begin
	or_l:
	for i in size-1 downto 1 generate
		or_ladder(i) <= or_ladder(i-1) or in0(i);
	end generate;
	or_ladder(0) <= in0(0) or in0(1);
	out0 <= or_ladder(size-1);
end rtl;