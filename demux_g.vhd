library ieee;
use ieee.numeric_bit.all;

entity demux_g is
	generic (
		size : integer := 1 -- addr space
	);
	port (
		en : in bit;
		s : in bit_vector(size-1 downto 0);
		q : out bit_vector(2**size-1 downto 0)
	);
end demux_g;

architecture rtl of demux_g is
	component and_g is
		generic (
			size : integer := 8
		);
		port (
			in0 : in bit_vector(size-1 downto 0);
			out0 : out bit
		);
	end component;
	type decode_array_type is array (2**size-1 downto 0) of bit_vector(size-1 downto 0);
	signal decode_pattern : decode_array_type;
	signal decode_bit : bit_vector(2**size-1 downto 0);
begin
	decoder:
	for i in 2**size-1 downto 0 generate
		decode_pattern(i) <= not bit_vector(to_unsigned(i,size)) xor s;
		d_and : and_g generic map (size => size) port map (
			in0 => decode_pattern(i), out0 => decode_bit(i)
		);
	end generate decoder;
	dmx_gen:
	for i in 2**size-1 downto 0 generate
		q(i) <= en and decode_bit(i);
	end generate dmx_gen;
end rtl;