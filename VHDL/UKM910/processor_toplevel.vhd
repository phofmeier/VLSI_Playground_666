----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    20:13:54 06/04/2017
-- Design Name:
-- Module Name:    processor_toplevel - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;


entity processor_toplevel is
   port( reset : in std_logic;
         clk   : in std_logic );
end processor_toplevel;

use work.all;

architecture behavioral of processor_toplevel is

   signal oe         :  std_logic;
   signal wren       :  std_logic;
   signal addressbus :  std_logic_vector (11 downto 0);
   signal databus    :  std_logic_vector (15 downto 0);
   signal interrupt  :  std_logic_vector (7 downto 0) := (others => '0');

begin

   ukm: entity UKM910
   port map(
      clk => clk,
      reset => reset,
      interrupt => interrupt
      oe => oe,
      wren => wren,
      addressbus => addressbus,
      databus => databus
   );

   mem: entity memory(Synthesis)
   port map(
      clk => clk,
      addr => addressbus(10 downto 0),
      dataIO => databus,
      wren => wren,
      oe => oe
   );

end;