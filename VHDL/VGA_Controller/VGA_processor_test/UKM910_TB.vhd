----------------------------------------------------------------------------------
-- Engineer:       Nicholas Feix
--
-- Create Date:    12:50:01 05/17/2017
-- Design Name:
-- Module Name:    UKM910_TB - Behavioral
--
----------------------------------------------------------------------------------
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
   signal we         :  std_logic;
   signal reset      :  std_logic;
   signal clk        :  std_logic;
   signal addressbus :  std_logic_vector (11 downto 0);
   signal databus    :  std_logic_vector (15 downto 0);
   signal interrupt  :  std_logic_vector (7 downto 0) := (others => '0');

begin

   ukm: entity UKM910
   port map(
      oe => oe,
      we => we,
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
      we => we,
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

   createInterrupt : process
   begin
       wait for 8520 ns;
       interrupt(1) <= '1';
       wait for 20 ns;
       interrupt(1) <= '0';
       wait;
   end process createInterrupt;

end;
