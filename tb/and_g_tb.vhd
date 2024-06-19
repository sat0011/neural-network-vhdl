library ieee;
use ieee.numeric_bit.all;

entity and_g_tb is
end and_g_tb;

architecture rtl of and_g_tb is
	component and_g is
		generic (
			size : integer := 8
		);
		port (
			in0 : in bit_vector(size-1 downto 0);
			out0 : out bit
		);
	end component;
	signal in0 : bit_vector(15 downto 0);
	signal out0 : bit;
begin
	t_and : and_g generic map (size => 16) port map (
		in0 => in0, out0 => out0
	);
	process begin
		for i in (2**16)-1 downto 0 loop
			in0 <= bit_vector(to_unsigned(i,16));
			wait for 1 ns;
		end loop;
		in0 <= "1111111111111111";
		wait for 1 ns;
		
	wait;
	end process;
end rtl;