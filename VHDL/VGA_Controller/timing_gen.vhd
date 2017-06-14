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
signal hcount        : integer   := TDISP_HSYNC - 1;
signal vcount        : integer   := TDISP_VSYNC - 1;

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
      hcount   <= TDISP_HSYNC - 1;
      vcount   <= TDISP_VSYNC - 1;
      hsync    <= '1';
      vsync    <= '1';

   elsif (rising_edge(pixel_clk)) then
      if hcount = (TS_HSYNC-1) then  --reset horizontal pixel count
         hcount <= 0;
      elsif hcount = TDISP_HSYNC then
         hcount <= hcount + 1;   --increment horizontal pixel count
         if vcount = (TS_VSYNC-1) then
            vcount <= 0;             --reset vertical pixel count
         else
            vcount <= vcount + 1;    --increment vertical pixel count
            if ((vcount >= (TDISP_VSYNC + TFP_VSYNC - 1)) and (vcount < (TS_VSYNC - TBP_VSYNC - 1))) then
               vsync <= '0'; --vertical sync pulse generation
            else
               vsync <= '1';
            end if;
         end if;
      else
         hcount <= hcount + 1;   --increment horizontal pixel count
         if ((hcount >= (TDISP_HSYNC + TFP_HSYNC)) and (hcount < (TS_HSYNC - TBP_HSYNC))) then
            hsync <= '0'; --horizontal sync pulse generation
         else
            hsync <= '1';
         end if;
      end if;
   end if;

   if ( (hcount < (TDISP_HSYNC)) and
        (vcount < (TDISP_VSYNC)) ) then
      image_enable <= '1';
   else
      image_enable <= '0';
   end if;

   -- if ( (image_enable = '1') and (hcount > 200) and (hcount < 400) and
   --      (vcount > 100) and (vcount < 400)) then
   --    red   <= '1';
   --    green <= '1';
   --    blue  <= '0';

   if ( (image_enable = '1') and (hcount = 0 or hcount = (TDISP_HSYNC-1)) ) then
      red   <= '0';
      green <= '0';
      blue  <= '1';

   elsif ( (image_enable = '1') and (vcount = 0 or vcount = (TDISP_VSYNC-1)) ) then
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







