entity mul_control_tb is
end mul_control_tb;

architecture rtl of mul_control_tb is
	component mul_control is
		port (
			clk : in bit;
			en : in bit;
			state : out bit;
			w_en, s_en, r_en : out bit;
			reset : out bit;
			next_w : out bit
		);
	end component;
	
	signal clk, en : bit;
	signal state : bit;
	signal r_en, w_en, s_en, reset : bit;
	signal next_w : bit;
begin
	t_mul_control : mul_control port map (
		clk => clk, en => en,
		state => state,
		w_en => w_en, s_en => s_en, r_en => r_en,
		reset => reset,
		next_w => next_w
	);
	process
		variable shift_count : integer;
		variable write_count : integer;
	begin
		en <= '1';
		clk <= '1';
		wait for 1 ns;
		en <= '0';
		shift_count := 0;
		write_count := 0;
		for i in 0 to 63 loop
			if w_en='1' then
				write_count := write_count + 1;
			end if;
			if s_en='1' then
				shift_count := shift_count + 1;
			end if;
			clk <= '0';
			wait for 1 ns;
			clk <= '1';
			wait for 1 ns;
			--assert false report "cycle " & integer'image(i) severity note;
		end loop;
		assert false report "write count: " & integer'image(write_count) severity note;
		assert false report "shift count: " & integer'image(shift_count) severity note;
		wait;
	end process;
end rtl;