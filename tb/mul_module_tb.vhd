entity mul_module_tb is
end mul_module_tb;

architecture rtl of mul_module_tb is
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

	component mul_module is
		port (
			neural_in  : in bit_vector(15 downto 0);
			clk : in bit;
			w_in : in bit;
			neural_acc_out : out bit_vector(31 downto 0);
			wen,ren,sen : in bit;
			reset : in bit
		);	
	end component;
	signal neural_in : bit_vector(15 downto 0);
	signal w_in_vec	: bit_vector(15 downto 0);
	signal clk, w_in : bit;
	signal neural_acc_out : bit_vector(31 downto 0);
	signal wen, sen, ren : bit;
	signal reset : bit;
begin
	w_mul_module : mul_module port map (
		neural_in => neural_in, clk => clk, w_in => w_in,
		neural_acc_out => neural_acc_out,
		wen => wen, ren => ren, sen => sen,
		reset => reset
	);
	
	process
		type pattern_type is record
			wen, ren, sen : bit;
			clk : bit;
		end record;
		type pattern_array is array (natural range <>) of pattern_type;
		constant patterns : pattern_array := (
			(wen => '1', ren => '1', sen => '0', clk => '0'),
			(wen => '1', ren => '1', sen => '0', clk => '1'), -- first step add
			(wen => '0', ren => '1', sen => '1', clk => '0'),
			(wen => '0', ren => '1', sen => '1', clk => '1'), -- shift left
			(wen => '1', ren => '1', sen => '0', clk => '0'),
			(wen => '1', ren => '1', sen => '0', clk => '1'), -- second step add
			(wen => '0', ren => '1', sen => '1', clk => '0'),
			(wen => '0', ren => '1', sen => '1', clk => '1') -- shift left
		);
		type test_inputs is record
			neural_in, weight : bit_vector(15 downto 0);
			res : bit_vector(31 downto 0);
		end record;
		type test_array is array (natural range <>) of test_inputs;
		constant tests : test_array := (
			(neural_in => "0000000000001111", weight => "0000000000001100", res => "00000000000000000000000010110100"), 
			(neural_in => "0000000011011000", weight => "0000000100101100", res => "00000000000000001111110100100000"), 
			(neural_in => "1111111111111111", weight => "1111111111111111", res => "11111111111111100000000000000001")
		);
		-- 12 * 15 = 180
		-- 216 * 300 - 64800
		-- 65535 * 65535 (max)
	begin
		neural_in <= "0000000011011000"; -- 216 * 300 = 64800
		--w_in_vec <=  "0000000100101100"; -- reversed on input
		ren <= '1';
		--(neural_acc_out => "0000000000001111", )
		for i in tests'range loop
			neural_in <= tests(i).neural_in;
			w_in_vec <= tests(i).weight;
			wait for 1 ns;
			for j in 15 downto 0 loop
				w_in <= w_in_vec(j);
				clk <= '0';
				wen <= '1';
				sen <= '0';
				wait for 1 ns;
				clk <= '1';
				wen <= '1';
				sen <= '0';
				wait for 1 ns; -- add
				clk <= '0';
				wen <= '0';
				sen <= '1'; --shift left
				wait for 1 ns;
				clk <= '1';
				wen <= '0';
				sen <= '1';
				wait for 1 ns;
			end loop;	
			assert false report "accumulator value : " & bitvec_to_str(neural_acc_out) severity note;
			assert neural_acc_out=tests(i).res report "result erorr" severity error;
			clk <= '1';
			sen <= '0';
			wen <= '1';
			reset <= '1';
			wait for 1 ns;
			reset <= '0';
			clk <= '0';
		end loop;
		wait;
	end process;
end rtl;	