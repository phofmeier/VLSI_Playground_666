----------------------------------------------------------------------------------
-- Engineer:       Nicholas Feix
--
-- Create Date:    15:30:06 06/17/2017
-- Design Name:
-- Module Name:    vga_timing - Behavioral
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;


entity vga_timing is
   port ( hsync      : out std_logic;
          vsync      : out std_logic;
          pixel_clk  : out std_logic;
          pixel_en   : out std_logic;
          pixel_top  : out std_logic;
          pixel_left : out std_logic;
          clk        : in  std_logic;
          reset      : in  std_logic );
end vga_timing;

architecture Behavioral of vga_timing is

   type STATES is (
      DISPLAY, FRONT_PORCH, PULSE, BACK_PORCH );

   signal state_h, next_state_h : STATES := FRONT_PORCH;
   signal state_v, next_state_v : STATES := FRONT_PORCH;

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

   signal clk_half      : std_logic := '0';
   signal count_h, next_count_h : integer := TDISP_HSYNC;
   signal count_v, next_count_v : integer := TDISP_VSYNC;

begin

-- clock_divide: process(clk, reset)
-- begin
--    if ( reset = '1' ) then
--       clk_half <= '0';
--    elsif ( rising_edge(clk) ) then
--       clk_half <= not clk_half;
--    end if;
-- end process clock_divide;

state_reg: process(clk, reset) begin
   if reset = '1' then
      clk_half <= '0';
      state_h <= FRONT_PORCH;
      state_v <= FRONT_PORCH;
      count_h <= TDISP_HSYNC;
      count_v <= TDISP_VSYNC;
   elsif ( rising_edge(clk) ) then
   --elsif rising_edge(clk_half) then
      if clk_half = '0' then
         clk_half <= '1';
         state_h <= next_state_h;
         state_v <= next_state_v;
         count_h <= next_count_h;
         count_v <= next_count_v;
      else
         clk_half <= '0';
      end if;
   end if;
end process;

timing_gen: process(state_h, state_v, count_h, count_v)
begin
   next_state_h <= state_h;
   next_state_v <= state_v;
   next_count_h <= count_h + 1;
   next_count_v <= count_v;
   pixel_top    <= '0';
   pixel_left   <= '0';

   case ( state_h ) is
      when DISPLAY =>
         if ( count_h = (TDISP_HSYNC - 2) ) then
            if count_v = (TS_VSYNC - 1) then
               next_count_v <= 0;
            else
               next_count_v <= count_v + 1;
            end if;
         elsif ( count_h = (TDISP_HSYNC - 1) ) then
            next_state_h <= FRONT_PORCH;
         end if;
      when FRONT_PORCH =>
         if ( count_h = (TDISP_HSYNC + TFP_HSYNC - 1) ) then
            next_state_h <= PULSE;
         end if;
      when PULSE =>
         if ( count_h = (TDISP_HSYNC + TFP_HSYNC + TP_HSYNC - 1) ) then
            next_state_h <= BACK_PORCH;
         end if;
      when BACK_PORCH =>
         if ( count_h = (TDISP_HSYNC + TFP_HSYNC + TP_HSYNC + TBP_HSYNC - 2) ) then
            null;
         elsif ( count_h = (TDISP_HSYNC + TFP_HSYNC + TP_HSYNC + TBP_HSYNC - 1) ) then
            next_state_h <= DISPLAY;
            next_count_h <= 0;
            pixel_left   <= '1';
            if count_v = (TS_VSYNC - 1) then
               pixel_top <= '1';
            end if;
         end if;
      when others =>
         null;
   end case;

   case ( state_v ) is
      when DISPLAY =>
         if ( count_v = (TDISP_VSYNC - 1) ) then
            next_state_v <= FRONT_PORCH;
         end if;
      when FRONT_PORCH =>
         if ( count_v = (TDISP_VSYNC + TFP_VSYNC - 1) ) then
            next_state_v <= PULSE;
         end if;
      when PULSE =>
         if ( count_v = (TDISP_VSYNC + TFP_VSYNC + TP_VSYNC - 1) ) then
            next_state_v <= BACK_PORCH;
         end if;
      when BACK_PORCH =>
         if ( count_v = (TDISP_VSYNC + TFP_VSYNC + TP_VSYNC + TBP_VSYNC - 1) ) then
            next_state_v <= DISPLAY;
         end if;
      when others =>
         null;
   end case;

end process timing_gen;

   pixel_clk   <= clk_half;
   pixel_en    <= '1' when (state_h = DISPLAY) and (state_v = DISPLAY) else '0';
   hsync       <= '0' when (state_h = PULSE) else '1';
   vsync       <= '0' when (state_v = PULSE) else '1';

end Behavioral;
