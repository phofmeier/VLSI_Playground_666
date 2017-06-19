-- Vhdl test bench created from schematic C:\Daten\ISE\IntegrierteSchaltungenProjekt\UKM801.sch - Wed Jan 09 22:17:10 2008
--
-- Notes: 
-- 1) This testbench template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the unit under test.
-- Xilinx recommends that these types always be used for the top-level
-- I/O of a design in order to guarantee that the testbench will bind
-- correctly to the timing (post-route) simulation model.
-- 2) To use this template as your testbench, change the filename to any
-- name of your choice with the extension .vhd, and use the "Source->Add"
-- menu in Project Navigator to import the testbench. Then
-- edit the user defined section below, adding code to generate the 
-- stimulus for your design.
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY UNISIM;
USE UNISIM.Vcomponents.ALL;


ENTITY processor_toplevel IS
	port (
		 reset	:	IN	STD_LOGIC; 
		 clk	:	IN	STD_LOGIC; 
		 rot_a   : in    std_logic;
		 rot_b   : in    std_logic;
		 rot_btn : in    std_logic;
		 -- outputs to LEDs
		 leds    : out   std_logic_vector( 7 downto 0));
END processor_toplevel;

use work.all;

ARCHITECTURE behavioral OF processor_toplevel IS 

   COMPONENT UKM901
   PORT(  oe	:	OUT	STD_LOGIC; 
          wren	:	OUT	STD_LOGIC; 
          res	:	IN	STD_LOGIC; 
          clk	:	IN	STD_LOGIC; 
          addressbus	:	OUT	STD_LOGIC_VECTOR (11 DOWNTO 0); 
          databus	:	INOUT	STD_LOGIC_VECTOR (15 DOWNTO 0));
   END COMPONENT;
	
	COMPONENT memory
	PORT(
		clk : IN std_logic;
		addr : IN std_logic_vector(10 downto 0);
		wren : IN std_logic;
		oe : IN std_logic;       
		dataIO : INOUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;
	
	component debug_module
	  port (
		 -- clock and reset
		 clk     : in    std_logic;
		 rst     : in    std_logic; -- asynchronous, active high
		 -- processor bus
		 dataIO  : inout std_logic_vector(15 downto 0);
		 oe      : in    std_logic;
		 wren    : in    std_logic;
		 -- inputs from rotation encoder hardware
		 rot_a   : in    std_logic;
		 rot_b   : in    std_logic;
		 rot_btn : in    std_logic;
		 -- outputs to LEDs
		 leds    : out   std_logic_vector( 7 downto 0)
	  );
	END COMPONENT;

	SIGNAL oe	:	STD_LOGIC;
   SIGNAL wren	:	STD_LOGIC;
	SIGNAL oe_dbg	:	STD_LOGIC;
   SIGNAL wren_dbg	:	STD_LOGIC;
	SIGNAL oe_mem	:	STD_LOGIC;
   SIGNAL wren_mem	:	STD_LOGIC;
   SIGNAL addressbus	:	STD_LOGIC_VECTOR (11 DOWNTO 0);
   SIGNAL databus	:	STD_LOGIC_VECTOR (15 DOWNTO 0);

BEGIN

   UUT: UKM901 PORT MAP(
		oe => oe, 
		wren => wren, 
		res => reset, 
		clk => clk, 
		addressbus => addressbus, 
		databus => databus
   );
	
	mem: memory PORT MAP(
		clk => clk,
		addr => addressbus(10 downto 0),
		dataIO => databus,
		wren => wren_mem,
		oe => oe_mem 
	);
	
	dbg: debug_module PORT MAP(
		clk => clk,
		rst => reset,
		dataIO => databus,
		wren => wren_dbg,
		oe => oe_dbg,
		rot_a => rot_a,
		rot_b => rot_b,
		rot_btn => rot_btn,
		leds => leds
	);
	
	module_select: process(addressbus, oe, wren)
	begin
		if addressbus(11) = '1' then
			oe_dbg <= oe;
			wren_dbg <= wren;
			oe_mem <= '0';
			wren_mem <= '0';
		else
			oe_dbg <= '0';
			wren_dbg <= '0';
			oe_mem <= oe;
			wren_mem <= wren;
		end if;
	end process;

END;
