entity rsh_8b_tb is
end rsh_8b_tb;

architecture rtl of rsh_8b_tb is

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

	component rsh_8b is
		port (
			in0 : in bit_vector(7 downto 0);
			w_en, r_en, s_en: in bit;
			clk : in bit;
			out0 : out bit_vector(7 downto 0)
		);
	end component;
	signal in0 : bit_vector( 7 downto 0 );
	signal w_en, r_en, s_en : bit;
	signal clk : bit;
	signal out0 : bit_vector(7 downto 0);
begin
	t_rsh_8b : rsh_8b port map (
		in0 => in0,
		w_en => w_en, r_en => r_en, s_en => s_en, clk => clk,
		out0 => out0
	);
	process
		type pattern_type is record
			in0 : bit_vector(7 downto 0);
			w_en, r_en, s_en : bit;
		end record;
		type pattern_array is array (natural range <>) of pattern_type;
		constant patterns : pattern_array := (
			(in0 => "11111111", w_en => '1', r_en => '1', s_en => '0'),
			(in0 => "00000000", w_en => '0', r_en => '1', s_en => '1'),
			(in0 => "00000000", w_en => '0', r_en => '1', s_en => '1'),
			(in0 => "00000000", w_en => '0', r_en => '1', s_en => '1'),
			(in0 => "00000000", w_en => '0', r_en => '1', s_en => '1'),
			(in0 => "00000000", w_en => '0', r_en => '1', s_en => '1'),
			(in0 => "00000000", w_en => '0', r_en => '1', s_en => '1'),
			(in0 => "00000000", w_en => '0', r_en => '1', s_en => '1'),
			(in0 => "00000000", w_en => '0', r_en => '1', s_en => '1'),
			(in0 => "00000000", w_en => '0', r_en => '1', s_en => '1'),
			(in0 => "00000000", w_en => '0', r_en => '1', s_en => '1')
			
		);
		variable p_clk : bit;
	begin
		p_clk := '1';
		for i in patterns'range loop
			in0 <= patterns(i).in0;
			w_en <= patterns(i).w_en;
			r_en <= patterns(i).r_en;
			s_en <= patterns(i).s_en;
			clk <= p_clk;
			wait for 1 ns;
			p_clk := not p_clk;
			assert false report "out : " & bitvec_to_str(out0) severity note;
		end loop;
		wait;
	end process;
end rtl;