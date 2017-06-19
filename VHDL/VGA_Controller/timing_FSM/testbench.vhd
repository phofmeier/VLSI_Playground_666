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
use ieee.numeric_std.all;
use work.sim_bmppack.all;
use work.all;

entity testbench is
end testbench;

architecture Behavioral of testbench is
   signal clk, reset: std_logic;
   signal hsync, vsync, red, green, blue: std_logic;
   signal pixel_clk, pixel_en, pixel_top, pixel_left: std_logic;
   signal x, y, x_n, y_n : integer := 0;

begin
   timing_unit: entity vga_timing
   port map (
      clk         => clk,
      reset       => reset,
      hsync       => hsync,
      vsync       => vsync,
      pixel_clk   => pixel_clk,
      pixel_en    => pixel_en,
      pixel_top   => pixel_top,
      pixel_left  => pixel_left
   );

   uu2: entity vgaTesterDigInterface
   port map (
      vsync       => vsync,
      hsync       => hsync,
      red         => red,
      green       => green,
      blue        => blue
   );

image_generator: process(x, y, pixel_en, pixel_left)
begin
   if ( pixel_en = '1' ) then
      if ( pixel_left = '1' or x = 0 or x = (640-1) ) then
        red   <= '0';
        green <= '0';
        blue  <= '1';
      elsif ( y = 0 or y = (480-1) ) then
         red   <= '1';
         green <= '0';
         blue  <= '0';
      else
         red   <= '1';
         green <= '1';
         blue  <= '0';
      end if;
   else
      red   <= '0';
      green <= '0';
      blue  <= '0';
   end if;
end process image_generator;

position_reg: process(clk, pixel_clk, pixel_en, pixel_top, pixel_left)
begin
   if ( pixel_en = '1' ) then
      x_n <= x + 1;
   else
      x_n <= x;
   end if;

   if pixel_left = '1' then
      y_n <= y + 1;
   else
      y_n <= y;
   end if;

   if rising_edge(clk) then
      if pixel_clk = '0' then
         if pixel_left = '1' then
            x <= 0;
         else
            x <= x_n;
         end if;
         if pixel_top = '1' then
            y <= 0;
         else
            y <= y_n;
         end if;
      end if;
   end if;
end process position_reg;


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

