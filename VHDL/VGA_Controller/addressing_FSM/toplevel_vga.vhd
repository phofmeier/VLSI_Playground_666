----------------------------------------------------------------------------------
-- Engineer:       Nicholas Feix
--
-- Create Date:    15:30:06 06/17/2017
-- Design Name:
-- Module Name:    toplevel_vga - Behavioral
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.all;

entity toplevel_vga is
   port( reset       : in std_logic;
         clk         : in std_logic;
         hsync       : out std_logic;
         vsync       : out std_logic;
         red         : out std_logic;
         green       : out std_logic;
         blue        : out std_logic );
end toplevel_vga;

architecture Behavioral of toplevel_vga is

begin

   vga_unit: entity vga_controller
   port map (
      clk         => clk,
      reset       => reset,
      hsync       => hsync,
      vsync       => vsync,
      red         => red,
      green       => green,
      blue        => blue
   );

end Behavioral;

