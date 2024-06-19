library ieee;
use ieee.numeric_bit.all;

entity mux_g_tb is
end mux_g_tb;

architecture rtl of mux_g_tb is
	component mux_g is
		generic (
			size : integer := 1
		);
		port (
			in0 : in bit_vector(2**size-1 downto 0);
			s : in bit_vector(size-1 downto 0);
			out0 : out bit
		);
	end component;
	constant size : integer := 8;
	signal in0 : bit_vector(255 downto 0);
	signal s : bit_vector(7 downto 0);
	signal out0 : bit;
begin
	t_muxg : mux_g generic map (size => 8) port map (
		in0 => in0, s => s,
		out0 => out0
	);
	process begin
		in0 <= (6=>'1', 8 to 12=>'1', others=>'0');
		for i in 255 downto 0 loop
			s <= bit_vector(to_unsigned(i,8));
			wait for 1 ns;
		end loop;
		wait;
	end process;
end rtl;