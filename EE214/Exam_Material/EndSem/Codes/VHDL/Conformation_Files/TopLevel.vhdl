library ieee;
use ieee.std_logic_1164.all;

--TDI	Input	PIN_5	1	3.3-V LVTTL (default)		16mA (default)
--TDO	Output	PIN_3	1	3.3-V LVTTL (default)		16mA (default)
--TMS	Input	PIN_7	1	3.3-V LVTTL (default)		16mA (default)
--TRST	Input	PIN_21	1	3.3-V LVTTL (default)		16mA (default)
--TCLK	Input	PIN_23	1	3.3-V LVTTL (default)		16mA (default)

entity TopLevel is
	port (
		TDI  : in  std_logic;  	-- Test Data In
		TDO  : out std_logic;  	-- Test Data Out
		TMS  : in  std_logic;  	-- TAP controller signal
		TCLK : in  std_logic;  	-- Test clock
		TRST : in  std_logic  	-- Test reset
	);
end TopLevel; 

architecture Struct of TopLevel is

	--------------------------------------------------------------------------
	------------------number_of_inputs and number_of_outputs------------------
	--------------------------------------------------------------------------
	constant number_of_inputs  : integer := 18;
	constant number_of_outputs : integer := 8;
	--------------------------------------------------------------------------
	--------------------------------------------------------------------------

	component DUT  is
		port(input_vector: in  std_logic_vector(number_of_inputs  -1 downto 0);
			output_vector: out std_logic_vector(number_of_outputs -1 downto 0));
	end component DUT;

	component Scan_Chain is
		generic (
			in_pins : integer; -- Number of input pins
			out_pins : integer -- Number of output pins
		);
		port (
			TDI     : in  std_logic;
			TDO     : out std_logic;
			TMS     : in  std_logic;
			TCLK    : in  std_logic;
			TRST    : in  std_logic;
			dut_in  : out std_logic_vector(in_pins-1 downto 0);
			dut_out : in  std_logic_vector(out_pins-1 downto 0)
		);
	end component;
		
	signal input_vector  : std_logic_vector(number_of_inputs  -1 downto 0);
	signal output_vector : std_logic_vector(number_of_outputs -1 downto 0);

	signal scan_chain_parallel_in  : std_logic_vector(number_of_inputs  -1 downto 0);
	signal scan_chain_parallel_out : std_logic_vector(number_of_outputs -1 downto 0);

begin
	scan_instance: Scan_Chain
		generic map(in_pins => number_of_inputs, out_pins => number_of_outputs)
			port map (TDI => TDI,
					TDO => TDO,
					TMS => TMS,
					TCLK => TCLK,
					TRST => TRST,
					dut_in => scan_chain_parallel_in,
					dut_out => scan_chain_parallel_out);

	dut_instance: DUT 
		port map(input_vector => input_vector, output_vector => output_vector);

	input_vector 			<= scan_chain_parallel_in;
	scan_chain_parallel_out	<= output_vector;  
end Struct;
