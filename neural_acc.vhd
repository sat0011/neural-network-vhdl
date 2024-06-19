entity neural_acc is
	port (
		clk, en : in bit;
		reset : in bit;
		mul_acc : in bit_vector(15 downto 0);
		neural_sum : out bit_vector(15 downto 0)
	);

end neural_acc;

architecture rtl of neural_acc is
	component dt_fall is
		port (
			d, clk : in bit;
			q : out bit
		);
	end component;
	component f_a is
		port (
			a, b, ci : in bit;
			s, co : out bit
		);
	end component;
	
	signal dt_en : bit;
	signal dt_in : bit_vector(15 downto 0);
	signal dt_out : bit_vector(15 downto 0);
	signal acc_carry : bit_vector(15 downto 0);
	signal acc_sum : bit_vector(15 downto 0);
begin
	dt_en <= clk and en;
	
	accumulator:
	for i in 15 downto 0 generate
		right_addr:
		if i=0 generate
			a_fa : f_a port map (
				a => mul_acc(i), b => dt_out(i), ci => '0',
				co => acc_carry(i), s => acc_sum(i)
			);
		end generate right_addr;
		othr_addr:
		if i>0 generate
			a_fa : f_a port map (
				a => mul_acc(i), b => dt_out(i), ci => acc_carry(i-1),
				co => acc_carry(i), s => acc_sum(i)
			);
		end generate othr_addr;
		
		-- data array
		dt_in(i) <= acc_sum(i) and not reset;
		a_dt : dt_fall port map (
			d => dt_in(i), clk => dt_en,
			q => dt_out(i)
		);
	end generate accumulator;
	
	neural_sum <= dt_out;
end rtl;