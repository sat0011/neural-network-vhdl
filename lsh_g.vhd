entity lsh_g is
	generic (
		data_width : integer := 8
	);
	port (
		in0 : in bit_vector(data_width-1 downto 0);
		w_en, r_en, s_en, clk : in bit;
		g_en : in bit;
		out0 : out bit_vector(data_width-1 downto 0)
	);
end lsh_g;

architecture rtl of lsh_g is
	component dt_fall is
		port (
			d, clk : in bit;
			q : out bit
		);
	end component;
	signal dt_out, dt_in : bit_vector(data_width-1 downto 0);
	signal d_clk : bit;
begin
	d_clk <= not clk and g_en;
	dt_array: 
	for i in data_width-1 downto 0 generate
		right_most:
		if i=0 generate
			dt_in(i) <= in0(i) and w_en;
		end generate right_most;
		other:
		if i>0 generate
			dt_in(i) <= (in0(i) and w_en) or (dt_out(i-1) and s_en and not w_en);
		end generate other;
		s_dt : dt_fall port map (
			d => dt_in(i), clk => d_clk,	
			q => dt_out(i)
		);
		out0(i) <= dt_out(i) and r_en;
	end generate dt_array;
end rtl;