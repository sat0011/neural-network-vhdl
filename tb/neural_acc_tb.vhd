entity neural_acc_tb is
end neural_acc_tb;

architecture rtl of neural_acc_tb is
	component neural_acc is
		port (
			clk, en : in bit;
			reset : in bit;
			mul_acc : in bit_vector(15 downto 0);
			neural_sum : out bit_vector(15 downto 0)
		);
	end component;
	signal clk, en, reset : bit;
	signal mul_acc, neural_sum : bit_vector(15 downto 0);
begin
	w_neural_acc : neural_acc port map (
		clk => clk, en => en, 
		reset => reset,
		mul_acc => mul_acc,
		neural_sum => neural_sum
	);
	process begin
		mul_acc <= "0000000000000011";
		clk <= '0';
		wait for 1 ns;
		clk <= '1';
		en <= '1';
		wait for 1 ns;
		for i in 0 to 5 loop
			clk <= '0';
			wait for 1 ns;
			clk <= '1';
			wait for 1 ns;
		end loop;
		wait;
	end process;
end rtl;