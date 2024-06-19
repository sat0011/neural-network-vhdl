library ieee;
use ieee.numeric_bit.all;

entity layer_tb is
end layer_tb;

architecture rtl of layer_tb is
	component layer is
		generic (
			neuron_count : integer := 4;
			addr_space : integer := 2
		);
		port (
			act_neuron : in bit_vector(addr_space-1 downto 0);
			prev_layer : in bit_vector(15 downto 0);
			clk : in bit;
			layer_out : out bit_vector(15 downto 0);
			
			-- neuron control signals
			wen,ren,sen,gen : in bit;
			mul_reset : in bit;
			req_wbit : in bit_vector(3 downto 0);
			write_in : in bit_vector(15 downto 0); -- for writing
			weight_write : in bit;
			nacc_en, nacc_reset : in bit
		);
	end component;
	signal act_neuron : bit_vector(addr_space-1 downto 0);
	signal prev_layer, layer_out : bit_vector(15 downto 0);
	signal clk : in bit;
	-- neuron controls
	signal wen,sen,ren,gen : bit;
	signal req_wbit : bit_vector(3 downto 0);
	signal write_in : bit_vector(15 downto 0);
	signal weight_write, nacc_en, nacc_reset : bit;
	-- to test practicality of each method, some of controls rely on master control unit and some rely on modules themselves
	-- for example next_w, which is controlled by mul_module and not by neuron_control
begin
	w_layer : layer generic map (addr_space => 2, neuron_count => 4) port map (
		act_neuron => act_neuron, prev_layer => prev_layer, clk => clk,
		
		wen => wen, ren => ren, sen > sen, gen => gen, mul_reset => mul_reset, 
		req_wbit => req_wbit, 
		write_in => write_in, weight_write => weight_write, nacc_en => nacc_en, nacc_reset => nacc_reset
	);
	process
		type weights_type is array (natural range <> ) of bit_vector(15 downto 0);
		constant n0_weights : weights_type := (
			"0010000000000001",
			"0010000000000010",
			"0010000000000011",
			"0010000000000100",
		);
		constant n1_weights : weights_type := (
			"0100000000000001",
			"0100000000000010",
			"0100000000000011",
			"0100000000000100"		
		);
		constant n2_weights : weights_type := (
			"0110000000000001",
			"0110000000000010",
			"0110000000000011",
			"0110000000000100"		
		);
		constant n3_weights : weights_type := (
			"1000000000000001",
			"1000000000000010",
			"1000000000000011",
			"1000000000000100"		
		);
	begin
		for i in 0 to 3 loop
			act_neuron <= bit_vector(to_unsigned(i,2));
		end loop;
	end process;
end rtl;