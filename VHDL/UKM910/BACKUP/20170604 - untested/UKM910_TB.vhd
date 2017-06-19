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
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library UNISIM;
use UNISIM.Vcomponents.all;
entity UKM910_TB is
end UKM910_TB;

use work.all;

architecture Behavioral of UKM910_TB is

   signal oe         :  std_logic;
   signal wren       :  std_logic;
   signal reset      :  std_logic;
   signal clk        :  std_logic;
   signal addressbus :  std_logic_vector (11 downto 0);
   signal databus    :  std_logic_vector (15 downto 0);
   signal interrupt  :  std_logic_vector (7 downto 0) := x"00";

begin

   ukm: entity UKM910
   port map(
      oe => oe,
      wren => wren,
      reset => reset,
      clk => clk,
      addressbus => addressbus,
      databus => databus,
		interrupt => interrupt
   );

   mem: entity memory(Simulation)
   port map(
      clk => clk,
      addr => addressbus(10 downto 0),
      dataIO => databus,
      wren => wren,
      oe => oe
   );

   createReset : process
   begin
      reset <= '1';
      wait for 150 ns;
      reset <= '0';
      WAIT;
   end process createReset;

   createClock : process
   begin
      clk <= '0';
      wait for 100 ns;
      clk <= '1';
      wait for 100 ns;
   end process createClock;

end;
