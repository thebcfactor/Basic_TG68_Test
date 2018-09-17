--------------------------------------------------------
--	"TG68 Basic Test"
--
--	Implement and test the TG68 core in the most simple
--	way possible.  This project is a recreation of one
--	found over at RetroRamblings.net called
-- 	"Experimenting with TG68".  The TG68 core file were
--	retrieved from the OpenCores website.
--
--	  By:	Brian Christian
--	Date:	September 16, 2018
--------------------------------------------------------


library ieee;					-- Include IEEE library files.
use ieee.std_logic_1164.all;	-- Use the "Standard Logic" functions from IEEE library.
use ieee.numeric_std.all;		-- Use the "Numeric/Math" functions from IEEE library.


-- ENTITY DECLARATION
--		This names this module and describes that signals are
--		to be made external.
entity TG68_BasicTest is

	port(
			-- 50MHz Clock Input
			CLOCK_50_B5B	: in	std_logic;
			
			-- Quad 7-Segment Displays
			HEX0			: out	std_logic_vector(6 downto 0);	-- HEX Digit 0 (Right/LSD)
			HEX1			: out	std_logic_vector(6 downto 0);	-- HEX Digit 1
			HEX2			: out	std_logic_vector(6 downto 0);	-- HEX Digit 2
			HEX3			: out	std_logic_vector(6 downto 0);	-- HEX Digit 3 (Left/MSD)
			
			-- Green LEDs
			LEDG			: out	std_logic_vector(7 downto 0);
			
			-- Reset Button
			KEY				: in	std_logic_vector(3 downto 0)
		);

end entity;


-- ARCHITECTURE DECLARATION
--		This is where the actual functionality of this module
--		is described.  The name is "TG68_BasicTest" (which must
--		match the entity name above) and "rtl" is a descriptor
--		of how the module is coded. (I don't know if the
--		descriptor type is really important as no matter what
--		type I choose it always seems to behave the same.)
architecture rtl of TG68_BasicTest is
-- Here is where the local signals and external
--		modules are placed.  (Between the "architecture" and
--		"begin" statements.)


	-- Declare TG68 component and it's signals.
	component TG68 is
		port(
				clk			: in	std_logic;						-- Clock
				reset		: in	std_logic;						-- /Reset (Active Low)
				clkena_in	: in	std_logic;						-- Clock Enable (Active High)
				data_in		: in	std_logic_vector(15 downto 0);	-- Data Bus In
				IPL			: in	std_logic_vector( 2 downto 0);	-- Interrput Priority Level
				dtack		: in	std_logic;						-- /Data Acknowledge Strobe (Active Low)
				addr		: out	std_logic_vector(31 downto 0);	-- Address Bus
				data_out	: out	std_logic_vector(15 downto 0);	-- Data Bus Out
				as			: out	std_logic;						-- /Address Strobe (Active Low)
				uds			: out	std_logic;						-- /Upper Data Strobe (Active Low)
				lds			: out	std_logic;						-- /Lower Data Strobe (Active Low)
				rw			: out	std_logic;						-- Read-/Write Control Out (High=Read, Low=Write)
				drive_data	: out	std_logic						-- Drive Data Control (Active High?)
			);
	end component;


	-- Create local signals inside this module.
	signal cpu_clk			: std_logic;						-- CPU's clock signal generated from Clock Divider.
	signal clk_count		: integer range 0 to 50000001;		-- Buffer that holds counted value for Clock Divider.
	signal divider			: integer range 0 to 50000000;		-- Buffer that holds the divisior for Clock Divider.
	signal cpu_data_in		: std_logic_vector(15 downto 0);	-- Data going into CPU.
	signal cpu_data_out		: std_logic_vector(15 downto 0);	-- Data coming from CPU.
	signal cpu_address		: std_logic_vector(31 downto 0);	-- Address from CPU.
	signal cpu_dtack		: std_logic;						-- /Data Acknowledge to CPU.
	signal cpu_as			: std_logic;						-- /Address Strobe from CPU.
	signal cpu_uds			: std_logic;						-- /Upper Byte Data Strobe from CPU.
	signal cpu_lds			: std_logic;						-- /Lower Byte Data Strobe from CPU.
	signal cpu_rw			: std_logic;						-- Read-/Write control from CPU.
	signal counter			: std_logic_vector(15 downto 0);	-- Buffer that's hold software counter's value.
	
	type hex_array_type
		is array (0 to 15) of std_logic_vector(6 downto 0);		-- Create an array. (16 words of 7 bits)
	signal hex_digit		: hex_array_type;					-- Create buffer to hold array.  (This is
																-- 		where we will store the patterns
																-- 		for the 7-Segment/HEX display.)

begin
-- Here is where the actual description of the
-- 		logic goes.  (Between the "begin" and
--		"end" statements.)


	-- CLOCK DIVIDER
	--		Slow the 50MHz clock down to something that
	--		we can watch.
	divider <= 500000;	-- Set the divider to 500,000 (50Mhz input clock / 500,000 divider /2 = 50Hz output clock)
	process(CLOCK_50_B5B)						-- Group all of the Clock Divider statements in a process.
	begin
		if (rising_edge(CLOCK_50_B5B)) then		-- On the rising edge of each input clock pulse...
			if (clk_count < divider) then		-- 		If the clock's "counter" is less than the set "divider"...
				clk_count <= clk_count + 1;		-- 		Add one (+1) to the "counter".
			else								-- If the clock's "counter" is more than the set "divider"...
				clk_count <= 0;					--		Reset the "counter" back to zero...
				cpu_clk <= not cpu_clk;			--		Toggle the output clock signal. (This toggling is the extra /2.)
			end if;
		end if;
	end process;
	
	
	-- Link the CPU Clock to a green LED so we have
	--		come visual confirmation of the clock.
	LEDG(0) <= cpu_clk;
	
	
	-- INSTANTIATE TG68 COMPONENT
	--		This creates an instance of the TG68 component
	--		called "Processor" and links signals to the
	--		TG68 component.
	Processor : TG68
	   port map(        
					clk			=> cpu_clk,			-- Link CPU's Clock (clk) with generated 50Hz "cpu_clk".
					reset		=> KEY(0),			-- Link CPU's /Reset (reset) to Key 0.
					clkena_in	=> '1',				-- Permanently enable the CPU's clock.
					data_in		=> cpu_data_in,		-- Link CPU's Data In Bus (data_in) to "cpu_data_in" signal.
					IPL			=> "111",			-- Set IPL all ones. (We aren't using interrputs anyways.)
					dtack		=> cpu_dtack,		-- Link CPU's /Data Acknowledge (dtack) to "cpu_dtack" signal.
					addr		=> cpu_address,		-- Link CPU's Address Bus (addr) to "cpu_address" signal.
					data_out	=> cpu_data_out,	-- Link CPU's Data Out Bus (data_out) to "cpu_data_out" signal.
					as			=> cpu_as,			-- Link CPU's /Address Strobe (as) to "cpu_as" signal.
					uds			=> cpu_uds,			-- Link CPU's /Upper Data Strobe (uds) to "cpu_uds" signal.
					lds			=> cpu_lds,			-- Link CPU's /Lower Data Strobe (lds) to "cpu_lds" signal.
					rw			=> cpu_rw			-- Link CPU's Read-/Write control to "cpu_rw" signal.
					-- drive_data	=>				-- (Unused Signal)
				);
	
	-- Simulate ROM & Counter Register
	process(cpu_clk,cpu_address)
	begin
		if (rising_edge(cpu_clk)) then				-- On the rising edge of the CPU Clock...
			if (cpu_as = '0') then					--		Check for a valid /Address Strobe.  If so then...
				case (cpu_address(23 downto 0)) is	--		Jump to the simulated address.
				
					when x"000000" =>				-- Address $000000
						cpu_data_in <= x"0000";		-- Initialize Stack Pointer to address $000008.
						cpu_dtack <= '0';			-- Acknowledge the bus transfer.
						
					when x"000002" =>				-- Address $000002
						cpu_data_in <= x"0000";		-- (Continuation of stack pointer from above.)
						cpu_dtack <= '0';			-- Acknowledge the bus transfer.
						
					when x"000004" =>				-- Address $000004
						cpu_data_in <= x"0000";		-- Initialize Program Counter to address $000008.
						cpu_dtack <= '0';			-- Acknowledge the bus transfer.
				
					when x"000006" =>				-- Address $000006
						cpu_data_in <= x"0008";		-- (Continuation of program counter pointer from above.)
						cpu_dtack <= '0';			-- Acknowledge the bus transfer.
					
					when x"000008" =>				-- Address $000008	(Start of program execution.)
						cpu_data_in <= x"5240";		-- addq.w #1,d0		(Add value of 1 to register D0.)
						cpu_dtack <= '0';			-- Acknowledge the bus transfer.
						
					when x"00000A" =>				-- Address $00000A
						cpu_data_in <= x"33C0";		-- move.w d0, $dff180	(Move contents of register D0
													-- 						 memory location $F00000.)
						cpu_dtack <= '0';			-- Acknowledge the bus transfer.
						
					when x"00000C" =>				-- Address $00000C
						cpu_data_in <= x"00F0";		-- (Continuation of move.w instruction.)
						cpu_dtack <= '0';			-- Acknowledge the bus transfer.
						
					when x"00000E" =>				-- Address $00000E
						cpu_data_in <= x"0000";		-- (Continuation of move.w instruction.)
						cpu_dtack <= '0';			-- Acknowledge the bus transfer.
						
					when x"000010" =>				-- Address $000010
						cpu_data_in <= x"4EF8";		-- jmp $000008	(Jump back to start of program execution.)
						cpu_dtack <= '0';			-- Acknowledge the bus transfer.
						
					when x"000012" =>				-- Address $000012
						cpu_data_in <= x"0008";		-- (Continuation of jmp instruction.)
						cpu_dtack <= '0';			-- Acknowledge the bus transfer.
						
					when x"F00000" =>				-- Address $F00000
						if (cpu_rw ='0' and cpu_uds = '0' and cpu_lds = '0') then	-- Check to make sure the CPU is only
																					--		writing to this location and
																					--		that it is a 16-bit transfer.
							counter <= cpu_data_out;	-- Place CPU's data bus into counter register.
							cpu_dtack <= '0';			-- Acknowledge the bus transfer.
						end if;
					
					when others =>				-- All other addresses...
						cpu_data_in <= x"4E71";	-- nop	(we should never get here.)
						cpu_dtack <= '0';		-- Acknowledge the bus transfer.
						
				end case;
			end if;
		end if;
	end process;
	
	
	-- HEX DISPLAY
	--		Place contects of software counter register onto
	--		the four 7-segment displays.
	
	-- Create a table containing the 16 different patterns to be displayed.
	hex_digit(0)  <= "0111111";	-- Pattern for the "0" digit.
    hex_digit(1)  <= "0000110";	-- Pattern for the "1" digit.
    hex_digit(2)  <= "1011011";	-- Pattern for the "2" digit.
    hex_digit(3)  <= "1001111";	-- Pattern for the "3" digit.
    hex_digit(4)  <= "1100110";	-- Pattern for the "4" digit.
    hex_digit(5)  <= "1101101";	-- Pattern for the "5" digit.
    hex_digit(6)  <= "1111101";	-- Pattern for the "6" digit.
    hex_digit(7)  <= "0000111";	-- Pattern for the "7" digit.
    hex_digit(8)  <= "1111111";	-- Pattern for the "8" digit.
    hex_digit(9)  <= "1101111";	-- Pattern for the "9" digit.
    hex_digit(10) <= "1110111";	-- Pattern for the "A" digit.
    hex_digit(11) <= "1111100";	-- Pattern for the "b" digit.
    hex_digit(12) <= "0111001";	-- Pattern for the "C" digit.
    hex_digit(13) <= "1011110";	-- Pattern for the "d" digit.
    hex_digit(14) <= "1111001";	-- Pattern for the "E" digit.
    hex_digit(15) <= "1110001";	-- Pattern for the "F" digit.
	
	-- Link the pattern to the ouput lines.  Each HEX digit/display
	--		will be connected to 4-bits.
	HEX0 <= not hex_digit( to_integer(unsigned(counter( 3 downto  0))) );	-- First Digit (LSD), Bits 0-3.
	HEX1 <= not hex_digit( to_integer(unsigned(counter( 7 downto  4))) );	-- Second Digit, Bits 4-7.
	HEX2 <= not hex_digit( to_integer(unsigned(counter(11 downto  8))) );	-- Third Digit, Bits 8-11.
	HEX3 <= not hex_digit( to_integer(unsigned(counter(15 downto 12))) );	-- Fourth Digit (MSD), Bits 12-15.

	
end rtl;
