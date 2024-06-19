entity mul_system_tb is
end mul_system_tb;

architecture rtl of mul_system_tb is
	component mul_module is
		port (
			neural_in  : in bit_vector(15 downto 0);
			clk : in bit;
			w_in : in bit;
			neural_acc_out : out bit_vector(31 downto 0);
			wen,ren,sen,gen,reset : in bit
		);
	end component;
	component mul_control is
		port (
			clk : in bit;
			en : in bit;
			state : out bit;
			w_en, s_en, r_en, g_en : out bit;
			reset : out bit;
			next_w : out bit
		);
	end component;

	signal en, clk : bit;
	signal state : bit;
	signal next_w : bit;
	
	signal wen, ren, sen, gen : bit;
	signal reset : bit;
	
	signal neural_in : bit_vector(15 downto 0);
	signal weight_vec : bit_vector(15 downto 0);
	signal w_in : bit;
	signal neural_acc_out : bit_vector(31 downto 0);
begin
	t_mul_module : mul_module port map (
		clk => clk, neural_in => neural_in, w_in => w_in,
		neural_acc_out => neural_acc_out,
		wen => wen, sen => sen, ren => ren, gen => gen,
		reset => reset
	);
	t_mul_control : mul_control port map (
		clk => clk, en => en,
		state => state,
		w_en => wen, s_en => sen, r_en => ren, g_en => gen,
		reset => reset,
		next_w => next_w
	);
	process
		type input_type is record
			neural_in, weight_vec : bit_vector(15 downto 0);
			neural_acc_out : bit_vector(31 downto 0);
		end record;
		type input_array is array (natural range <>) of input_type;
		constant inputs : input_array := (
			(neural_in => "1111111111111111", weight_vec => "1111111111111111", neural_acc_out => "11111111111111100000000000000001"),
			(neural_in => "0000000000010001", weight_vec => "0000000000001101", neural_acc_out => "00000000000000000000000011011101"),
			(neural_in => "0000000011011000", weight_vec => "0000000001001100", neural_acc_out => "00000000000000000100000000100000")
		);
		-- 17 * 13 = 221
		-- 216 * 76 = 16416
		variable w_index : integer;
		variable write_cycles : integer;
		variable shift_cycles : integer;
	begin
		
		for i in inputs'range loop
			en <= '1';
			clk <= '0';
			wait for 1 ns;
			clk <= '1';
			wait for 1 ns;
			w_index := 15;
			write_cycles := 0;
			shift_cycles := 0;
			en <= '0';
			neural_in <= inputs(i).neural_in;
			for j in 40 downto 0 loop
				if next_w='1' and w_index>0 then
					w_index := w_index - 1;
				end if;
				w_in <= inputs(i).weight_vec(w_index);
				if wen='1' then
				write_cycles := write_cycles + 1;
				end if;
				if sen='1' then
					shift_cycles := shift_cycles + 1;
				end if;	
				clk <= '0';
				wait for 1 ns;
				clk <= '1';
				wait for 1 ns;
			end loop;			
			assert neural_acc_out=inputs(i).neural_acc_out report "out error" severity error;
			assert false report "write cycles: " & integer'image(write_cycles) severity note;
			assert false report "shift cycles: " & integer'image(shift_cycles) severity note;
		end loop;
		wait;
	end process;
end rtl;	