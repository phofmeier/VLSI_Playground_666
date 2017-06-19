----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    18:47:30 06/08/2017
-- Design Name:
-- Module Name:    uut-VGA - Behavioral
----------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;


entity timing_module is
   port ( hsync   : out std_logic;
          vsync   : out std_logic;
          red     : out std_logic;
          green   : out std_logic;
          blue    : out std_logic;
          clk     : in  std_logic;
          reset   : in  std_logic );
end timing_module;

architecture timing of timing_module is

constant TS_HSYNC    : integer   := 800;
constant TFP_HSYNC   : integer   := 16;
constant TP_HSYNC    : integer   := 96;
constant TBP_HSYNC   : integer   := 48;
constant TDISP_HSYNC : integer   := 640;

constant TS_VSYNC    : integer   := 521;
constant TFP_VSYNC   : integer   := 10;
constant TP_VSYNC    : integer   := 2;
constant TBP_VSYNC   : integer   := 29;
constant TDISP_VSYNC : integer   := 480;

signal pixel_clk     : std_logic := '0';
signal image_enable  : std_logic := '0';
signal hcount        : integer   := 0;
signal vcount        : integer   := 0;
signal x, y          : integer   := 0;

begin

Clock_divide: process(clk,reset)
begin
   if (reset = '1') then
      pixel_clk <= '0';
   elsif(rising_edge(clk))then
      pixel_clk <= not pixel_clk;
   end if;
end process Clock_divide;

timing_gen: process(pixel_clk, reset)
begin

   if reset = '1' then
      hcount   <= 1;
      vcount   <= 1;
      hsync    <= '1';
      vsync    <= '1';

   elsif (rising_edge(pixel_clk)) then
      if hcount = TS_HSYNC then  --reset horizontal pixel count
         hcount <= 1;
         x <= 0;
         if vcount = TS_VSYNC then
            vcount <= 1;             --reset vertical pixel count
            y <= 0;
         else
            if ((vcount >= TFP_VSYNC) and (vcount < (TFP_VSYNC + TP_VSYNC))) then
            --if (vcount < TP_VSYNC) then
               vsync <= '0'; --vertical sync pulse generation
            else
               vsync <= '1';
            end if;
            vcount <= vcount + 1;    --increment vertical pixel count
            if ( vcount > (TFP_VSYNC + TP_VSYNC + TBP_VSYNC) ) then
               y <= y + 1;
            end if;
         end if;
      else
         if ((hcount >= TFP_HSYNC) and (hcount < (TFP_HSYNC + TP_HSYNC))) then
            hsync <= '0'; --horizontal sync pulse generation
         else
            hsync <= '1';
         end if;
         hcount <= hcount + 1;   --increment horizontal pixel count
         if ( hcount >= (TFP_HSYNC + TP_HSYNC + TBP_HSYNC) ) then
            x <= x + 1;
         end if;
      end if;
   end if;

   if ( (hcount >= (TFP_HSYNC + TP_HSYNC + TBP_HSYNC)) and
        (hcount <  (TFP_HSYNC + TP_HSYNC + TBP_HSYNC + TDISP_HSYNC)) and
        (vcount >  (TFP_VSYNC + TP_VSYNC + TBP_VSYNC)) and
        (vcount <= (TFP_VSYNC + TP_VSYNC + TBP_VSYNC + TDISP_VSYNC)) ) then
      image_enable <= '1';
   else
      image_enable <= '0';
   end if;

   -- if ( (image_enable = '1') and (hcount > 200) and (hcount < 400) and
   --      (vcount > 100) and (vcount < 400)) then
   --    red   <= '1';
   --    green <= '1';
   --    blue  <= '0';

   if ( (image_enable = '1') and (x = 0 or x = (TDISP_HSYNC-1)) ) then
      red   <= '0';
      green <= '0';
      blue  <= '1';

   elsif ( (image_enable = '1') and (y = 0 or y = (TDISP_VSYNC-1)) ) then
      red   <= '1';
      green <= '0';
      blue  <= '0';

   elsif (image_enable = '1') then
      red   <= '1';
      green <= '1';
      blue  <= '0';
   elsif (image_enable = '0') then
      red   <= '0';
      green <= '0';
      blue  <= '0';
   end if;

end process timing_gen;

end timing;







