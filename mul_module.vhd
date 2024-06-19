entity mul_module is
	port (
		neural_in  : in bit_vector(15 downto 0);
		clk : in bit;
		w_in : in bit;
		neural_acc_out : out bit_vector(31 downto 0);
		wen,ren,sen,gen,reset : in bit
	);	
end mul_module;

architecture rtl of mul_module is
	component d_t is
		port (
			d, clk : in bit;
			q : out bit
		);
	end component;
	component dt_fall is
		port (
			d, clk : in bit;
			q : out bit
		);
	end component;
	component lsh_g is
		generic (
			data_width : integer := 8
		);
		port (
			in0 : in bit_vector(data_width-1 downto 0);
			w_en, r_en, s_en, g_en, clk : in bit;
			out0 : out bit_vector(data_width-1 downto 0)
		);
	end component;
	component f_a is
		port (
			a, b, ci : in bit;
			s, co : out bit
		);
	end component;
	component h_a is
		port (
			a, b: in bit;
			s, co : out bit
		);
	end component;
	component sr_t is
		port (
			s, r, clk : in bit;
			q : out bit
		);
	end component;
	
	signal control_wen, control_ren, control_sen, control_gen : bit;
	
	signal mul_ready : bit_vector(15 downto 0);
	
	signal add_carry : bit_vector(15 downto 0);
	signal add_out : bit_vector(15 downto 0);
	signal sub_add_carry : bit_vector(31 downto 16);
	signal sub_add_out : bit_vector(31 downto 16);
	
	signal acc_out : bit_vector(31 downto 0);
	signal neural_acc_in : bit_vector(31 downto 0);
begin
	--testing
	control_wen <= wen;
	control_ren <= ren;
	control_sen <= sen;
	control_gen <= gen;

	adder_array:
	for i in 15 downto 0 generate
		mul_ready(i) <= w_in and neural_in(i);
		fst_addr: 
		if i=0 generate
			mul_add : f_a port map (
				a => mul_ready(i), b => acc_out(i), ci => '0',
				co => add_carry(i), s => add_out(i)
			);
		end generate fst_addr;
		other_addr:
		if i>0 generate
			mul_add : f_a port map (
				a => mul_ready(i), b => acc_out(i), ci => add_carry(i-1),
				co => add_carry(i), s => add_out(i)
			);
		end generate other_addr;
	end generate adder_array;
	
	sub_adder: 
	for i in 31 downto 15 generate
		right_subaddr:
		if i=16 generate
			sub_add : h_a port map (
				a => acc_out(i), b=>add_carry(15),
				s => sub_add_out(i), co => sub_add_carry(i)
			);
		end generate right_subaddr;
		other_subaddr:
		if i>16 generate
			sub_add : h_a port map (
				a => acc_out(i), b=>sub_add_carry(i-1),
				s => sub_add_out(i), co => sub_add_carry(i)
			);
		end generate other_subaddr;
	end generate sub_adder;
	
	neural_reg : lsh_g
	generic map (data_width => 32)
	port map (
		in0 => neural_acc_in, s_en => control_sen, w_en => control_wen, r_en => control_ren, g_en => control_gen,
		clk => clk,
		out0 => acc_out
	);
	neural_acc:
	for i in 31 downto 0 generate
		adder_acc_input:
		if i<=15 generate
			neural_acc_in(i) <= add_out(i) and not reset;
		end generate adder_acc_input;
		sub_adder_acc:
		if i>15 generate
			neural_acc_in(i) <= sub_add_out(i) and not reset;
		end generate sub_adder_acc;
	end generate neural_acc;
	
	output:
	for i in 31 downto 0 generate
		neural_acc_out(i) <= acc_out(i);
	end generate output;

end rtl;

-- 2,147,385,345 actuaд
-- 7FFE 8001
-- 0111 1111 1111 1110 1000 0000 0000 0001

-- 4,294,836,225 expected
-- FFFE 0001
-- 1111 1111 1111 1110 0000 0000 0000 0001