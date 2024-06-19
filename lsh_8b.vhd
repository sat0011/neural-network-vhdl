entity lsh_8b is
	port (
		in0 : in bit_vector(7 downto 0);
		w_en, r_en, s_en: in bit;
		clk : in bit;
		out0 : out bit_vector(7 downto 0)
	);
end lsh_8b;

architecture rtl of lsh_8b is
	component dt_fall is
		port (
			d, clk : in bit;
			q : out bit
		);
	end component;
	signal dt_out : bit_vector(7 downto 0);
	signal dt_in : bit_vector(7 downto 0);
begin
	dt_array:
	for i in 7 downto 0 generate
		left_most:
		if i=0 generate
			dt_in(i) <= in0(i) and w_en;
		end generate left_most;
		other:
		if i>0 generate
			dt_in(i) <= (in0(i) and w_en) or (dt_out(i-1) and s_en and not w_en);
		end generate other;
		s_dt : dt_fall port map (
			d => dt_in(i), clk => clk,
			q => dt_out(i)
		);
		out0(i) <= dt_out(i) and r_en;
	end generate dt_array;
	
end rtl;	