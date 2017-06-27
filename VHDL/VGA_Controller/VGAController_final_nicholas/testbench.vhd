----------------------------------------------------------------------------------
-- Engineer:       Nicholas Feix
--
-- Create Date:    15:30:06 06/17/2017
-- Design Name:
-- Module Name:    testbench - Behavioral
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use work.sim_bmppack.all;
use work.all;


entity testbench is
end testbench;

architecture Behavioral of testbench is
   signal clk, reset: std_logic;
   signal hsync, vsync, red, green, blue: std_logic;

begin
   vga_unit: entity vga_controller(Simulation)
   port map (
      clk         => clk,
      reset       => reset,
      addressbus  => (others => '0'),
      dataIN      => (others => '0'),
      we          => '0',
      hsync       => hsync,
      vsync       => vsync,
      red         => red,
      green       => green,
      blue        => blue
   );

   uu2: entity vgaTesterDigInterface
   port map (
      vsync       => vsync,
      hsync       => hsync,
      red         => red,
      green       => green,
      blue        => blue
   );

reset_driver:
   reset <= '1', '0' after 30 ns ;

clock_driver: process
   variable tmp_clk : std_logic := '1';
begin
   tmp_clk := not tmp_clk;
   clk <= tmp_clk;
   wait for 10 ns;
end process clock_driver;

end Behavioral;

