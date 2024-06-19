library ieee;
use ieee.numeric_bit.all;

entity mul_control is
	port (
		clk : in bit;
		en : in bit;
		state : out bit;
		w_en, s_en, r_en, g_en : out bit;
		reset : out bit;
		next_w : out bit
	);
end mul_control;

architecture rtl of mul_control is
	component jk_t is
		port (
			j, k, clk : in bit;
			q : out bit
		);
	end component;
	component sr_t is
		port (
			s, r, clk : in bit;
			q : out bit
		);
	end component;
	signal internal_state : bit;
	
	signal op_done : bit; 
	signal mul_reset : bit;
	
	signal jk_en_j : bit_vector(5 downto 0);
	signal jk_en_k : bit_vector(5 downto 0);
	signal c_clk : bit;
	signal c_reset : bit;
	signal step : bit_vector (5 downto 0);
	signal c_propagation : bit_vector(6 downto 1); -- 5th counts as full (11111)
begin

	state_sr : sr_t port map (
		s => en, r => c_reset, clk => clk,
		q => internal_state
	);
	step_counter:
	for i in 5 downto 0 generate
		right_most_c:
		if i<1 generate
			jk_en_j(i) <= not c_reset and internal_state;
			jk_en_k(i) <= internal_state or c_reset;
			c_jk : jk_t port map (j => jk_en_j(i), k => jk_en_k(i), clk => clk, q => step(i));
			c_propagation(1) <= jk_en_k(i) and step(i);
		end generate right_most_c;
		other_jk:
		if i>0 generate
			jk_en_j(i) <= not c_reset and c_propagation(i);
			jk_en_k(i) <= c_propagation(i) or c_reset;
			c_jk : jk_t port map (j => jk_en_j(i), k => jk_en_k(i), clk => clk, q => step(i));
			c_propagation(i+1) <= c_propagation(i) and step(i);
		end generate other_jk;
	end generate step_counter;
	
	c_reset <= not step(0) and not step(1) and not step(2) and not step(3) and not step(4) and step(5);
	state <= internal_state;
	
	r_en <= '1';
	g_en <= internal_state;
	mul_reset <= step(0) and not (step(1) or step(2) or step(3) or step(4) or step(5));
	w_en <= (not (step(0) and (step(1) or step(2) or step(3) or step(4) or step(5)) ) or mul_reset) and internal_state;
	s_en <= step(0) and (step(1) or step(2) or step(3) or step(4) or step(5));
	reset <= mul_reset;
	next_w <= (step(0) and not mul_reset and (step(1) or step(2) or step(3) or step(4) or step(5))) and internal_state;
	
end rtl;