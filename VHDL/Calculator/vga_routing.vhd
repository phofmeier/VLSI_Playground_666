----------------------------------------------------------------------------------
-- Engineer:       Nicholas Feix
--
-- Create Date:    11:03:06 06/27/2017
-- Design Name:
-- Module Name:    vga_routing - Behavioral
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use work.all;


entity vga_routing is
   port ( clk        : in  std_logic;
          reset      : in  std_logic;
          hsync      : out std_logic;
          vsync      : out std_logic;
          red        : out std_logic;
          green      : out std_logic;
          blue       : out std_logic;
          mem_data   : in  std_logic_vector(15 downto 0);
          addr_rd    : out std_logic_vector(10 downto 0);
          read_en    : out std_logic;
          colors     : in  std_logic_vector(5 downto 0) );
end vga_routing;

architecture Behavioral of vga_routing is
   signal pixel_clk, pixel_en, pixel_top, pixel_left: std_logic;
   signal read_en_sig, buffer_en : std_logic;
   signal byte_select : std_logic;
   signal row_select  : std_logic_vector(3 downto 0);
   signal bit_mask    : std_logic_vector(7 downto 0);

   signal char_reg  : std_logic_vector(15 downto 0);
   signal char_data : std_logic_vector(7 downto 0);
   signal pixel_row : std_logic_vector(7 downto 0);

begin
   timing_unit: entity vga_timing
   port map (
      clk         => clk,
      reset       => reset,
      hsync       => hsync,
      vsync       => vsync,
      pixel_clk   => pixel_clk,
      pixel_en    => pixel_en,
      pixel_top   => pixel_top,  -- comes one cycle before pixel_en
      pixel_left  => pixel_left  -- comes one cycle before pixel_en
   );

   addr_unit: entity vga_address_gen
   port map (
      address     => addr_rd,
      read_en     => read_en_sig,
      byte_select => byte_select,
      row_select  => row_select,
      bit_mask    => bit_mask,
      clk         => clk,
      pixel_clk   => pixel_clk,
      pixel_en    => pixel_en,
      pixel_top   => pixel_top,  -- comes one cycle before pixel_en
      pixel_left  => pixel_left  -- comes one cycle before pixel_en
   );

   char_unit: entity vga_character_rows
   port map (
      char_ascii  => char_data,
      char_row    => row_select,
      pixel_row   => pixel_row
   );

   image_generator: process(pixel_en, bit_mask, pixel_row, colors)
   begin
      if ( pixel_en = '1' ) then
         if ( or_reduce(pixel_row and bit_mask) = '1' ) then
            red   <= colors(2);
            green <= colors(1);
            blue  <= colors(0);
         else
            red   <= colors(5);
            green <= colors(4);
            blue  <= colors(3);
         end if;
      else
         red   <= '0';
         green <= '0';
         blue  <= '0';
      end if;
   end process image_generator;

   buffer_reg: process(clk)
   begin
      if rising_edge(clk) then
      --if rising_edge(pixel_clk) then
         if ( buffer_en = '1' ) then  -- and pixel_clk = '0'
            char_reg <= mem_data;
            buffer_en <= '0';
         else
            -- Delay the transfer to the buffer by one cycle
            buffer_en <= read_en_sig;
         end if;
      end if;
   end process;

   char_select_mux: process(byte_select, char_reg)
   begin
      if ( byte_select = '1' ) then
         char_data <= char_reg(15 downto 8);
      else
         char_data <= char_reg(7 downto 0);
      end if;
   end process;

   read_en <= read_en_sig;

end Behavioral;

