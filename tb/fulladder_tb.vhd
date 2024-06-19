library ieee;

use std.textio.all;

entity fulladder_tb is
end fulladder_tb;

architecture rtl of fulladder_tb is
	component fulladder is
		port (
			a, b, ci : in bit;
			s, co : out bit
		);
	end component;
	
	signal a,b,ci : bit;
	signal s,co : bit;
	
	function bitvec_to_str(inp: bit_vector) return string is
		variable temp: string(inp'left+1 downto 1);
	begin
		for i in inp'reverse_range loop
			if (inp(i) = '1') then
				temp(i+1) := '1';
			else temp(i+1) := '0';
			end if;
			--temp(i) := '1' when inp(i)='1' else '0';
		end loop;
		return temp;
	end function bitvec_to_str;
	
	function str_to_bitvec(inp: string) return bit_vector is
		variable temp: bit_vector(inp'left-1 downto 0);
	begin
		for i in inp'reverse_range loop
			if (inp(i) = '1') then temp(i-1) := '1'; else temp(i-1) := '0'; end if;
		end loop;
		return temp;
	end function str_to_bitvec;
begin	
	
	w_adder : fulladder port map (
		a => a, b => b, ci => ci,
		s => s, co => co
	);
	
	test_input : process
		file input_file : text;
		file out_file : text;
		
		variable input_line : line;
		variable input_str : string (3 downto 1);
		variable input_vec : bit_vector(2 downto 0);		
		
		variable output_vec : bit_vector(1 downto 0);
		variable output_str : string (3 downto 1);
	begin
		file_open(input_file, "fadder_test.txt", READ_MODE);
		file_open(out_file, "fadder_res.txt", WRITE_MODE);
		while not endfile(input_file) loop
			readline(input_file, input_line);
			read(input_line, input_vec);
			assert false report "input: " & bitvec_to_str(input_vec) severity note;
			
			a <= input_vec(0);
			b <= input_vec(1);
			ci <= input_vec(2);
			
			wait for 1 ns;
			assert a=input_vec(0) report "input assignment fail" severity error;
			output_vec(0) := s;
			output_vec(1) := co;
			assert false report "out: " & bitvec_to_str(output_vec) severity note;
			write(out_file, bitvec_to_str(output_vec));
			
		end loop;
		wait;
	end process test_input;
end rtl;