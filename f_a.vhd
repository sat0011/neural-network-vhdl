library ieee;

entity f_a is
	port (
		a, b, ci : in bit;
		s, co : out bit
	);
end f_a;

architecture rtl of f_a is

begin
	s <= a xor b xor ci;
	co <= (a and b) or (a and ci) or (b and ci);
end rtl;