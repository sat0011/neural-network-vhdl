entity mux is
	port (
		a, b, s : in bit;
		q : out bit
	);
end mux;

architecture rtl of mux is
begin
	q <= (not s and a) or (s and b);
end rtl;