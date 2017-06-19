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
ENTITY UKM901_TB IS
END UKM901_TB;

use work.all;

ARCHITECTURE behavioral OF UKM901_TB IS 

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

	SIGNAL oe	:	STD_LOGIC;
   SIGNAL wren	:	STD_LOGIC;
   SIGNAL res	:	STD_LOGIC;
   SIGNAL clk	:	STD_LOGIC;
   SIGNAL addressbus	:	STD_LOGIC_VECTOR (11 DOWNTO 0);
   SIGNAL databus	:	STD_LOGIC_VECTOR (15 DOWNTO 0);

BEGIN

   UUT: UKM901 PORT MAP(
		oe => oe, 
		wren => wren, 
		res => res, 
		clk => clk, 
		addressbus => addressbus, 
		databus => databus
   );
	
	mem: memory PORT MAP(
		clk => clk,
		addr => addressbus(10 downto 0),
		dataIO => databus,
		wren => wren,
		oe => oe 
	);
	
	createReset : PROCESS 
	BEGIN
		res <= '1';
		WAIT FOR 150 ns;
		res <= '0';
		WAIT;
	END PROCESS createReset;
	
	createClock : PROCESS
	BEGIN
		clk <= '0';
		WAIT FOR 100 ns;
		clk <= '1';
		WAIT FOR 100 ns;
	END PROCESS createClock;

END;
