library ieee;
use ieee.numeric_bit.all;

entity mux_g is
	generic (
		size : integer := 1
	);
	port (
		in0 : in bit_vector(2**size-1 downto 0);
		s : in bit_vector(size-1 downto 0);
		out0 : out bit
	);
end mux_g;

architecture rtl of mux_g is
	component and_g is
		generic (
			size : integer := 8
		);
		port (
			in0 : in bit_vector(size-1 downto 0);
			out0 : out bit
		);
	end component;
	component or_g is
		generic (
			size : integer := 8
		);
		port (
			in0 : in bit_vector(size-1 downto 0);
			out0 : out bit
		);
	end component;
	type s_type is array (2**size-1 downto 0) of bit_vector(size-1 downto 0);
	signal s_array : s_type;
	signal s_decoder : bit_vector(2**size-1 downto 0);
	signal in0_and : bit_vector(2**size-1 downto 0);
	
begin
	mux_and:
	for i in 0 to 2**size-1 generate
		s_array(i) <= not bit_vector(to_unsigned(i, size)) xor s;
		dec_and : and_g generic map (size => size) port map (in0 => s_array(i), out0 => s_decoder(i));
		in0_and(i) <= s_decoder(i) and in0(i);
	end generate mux_and;
	mux_or : or_g generic map(size => 2**size) port map (in0 => in0_and, out0 => out0);
end rtl;	
