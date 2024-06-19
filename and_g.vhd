entity and_g is
	generic (
		size : integer := 8
	);
	port (
		in0 : in bit_vector(size-1 downto 0);
		out0 : out bit
	);
end and_g;

architecture rtl of and_g is
	signal and_ladder : bit_vector(size-1 downto 0);
begin
	and_l:
	for i in size-1 downto 1 generate
		and_ladder(i) <= and_ladder(i-1) and in0(i);
	end generate;
	and_ladder(0) <= in0(0) and in0(1);
	out0 <= and_ladder(size-1);
end rtl;