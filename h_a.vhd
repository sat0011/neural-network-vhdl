entity h_a is
	port (
		a, b : in bit;
		s, co : out bit
	);
end entity h_a;

architecture rtl of h_a is
begin
	s <= a xor b;
	co <= a and b;
end rtl;