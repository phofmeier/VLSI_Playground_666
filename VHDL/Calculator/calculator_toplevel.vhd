----------------------------------------------------------------------------------
-- Engineer:       Nicholas Feix
--
-- Create Date:    13:34:00 06/9/2017
-- Design Name:
-- Module Name:    processor_toplevel - Behavioral
--
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_misc.ALL;
USE ieee.numeric_std.ALL;


entity calculator_toplevel is
   port( reset       : in std_logic;
         clk         : in std_logic;
         -- VGA IO pins
         hsync       : out std_logic;
         vsync       : out std_logic;
         red         : out std_logic;
         green       : out std_logic;
         blue        : out std_logic;
         -- PS2 IO pins
         ps2clk      : in std_logic;
         ps2data     : in std_logic );
end calculator_toplevel;

use work.all;

architecture Behavioral of calculator_toplevel is

   signal oe         : std_logic;
   signal we         : std_logic;
   signal oe_mem     : std_logic;
   signal we_mem     : std_logic;
   signal we_vga     : std_logic;
   signal oe_ps2     : std_logic;
   signal addressbus : std_logic_vector (11 downto 0) := (others => '0');
   signal databus    : std_logic_vector (15 downto 0) := (others => '0');
   signal interrupt  : std_logic_vector (7 downto 0);

   signal sel_mem    : std_logic;
   signal sel_vga    : std_logic;
   signal sel_ps2    : std_logic;

begin

   ukm: entity UKM910
   port map(
      clk         => clk,
      reset       => reset,
      interrupt   => interrupt,
      oe          => oe,
      we          => we,
      addressbus  => addressbus,
      databus     => databus
   );

   mem: entity memory(Synthesis)
   port map(
      clk      => clk,
      addr     => addressbus(10 downto 0),
      dataIO   => databus,
      we       => we_mem,
      oe       => oe_mem
   );

   vga_unit: entity vga_controller(Synthesis)
   port map (
      clk         => clk,
      reset       => reset,
      addressbus  => addressbus(10 downto 0),
      databus     => databus,
      we          => we_vga,
      hsync       => hsync,
      vsync       => vsync,
      red         => red,
      green       => green,
      blue        => blue
   );
   
   ps2_unit: entity PS2_Controller
   port map (
      clk         => clk,
      reset       => reset,
      databus     => databus,
      oe          => oe_ps2,
      interrupt   => interrupt(1),
      ps2clk      => ps2clk,
      ps2data     => ps2data
   );

   -- address decoding
   address_decode: process(addressbus)
   begin
      sel_mem  <= '0';
      sel_ps2  <= '0';
      sel_vga  <= '0';

      if ( addressbus(11) = '0' ) then
         sel_mem <= '1';
      elsif ( addressbus = x"FFF" ) then
         sel_ps2 <= '1';
      elsif ( addressbus < x"E40" ) then  -- 0x800 + 1600
         sel_vga <= '1';
      end if;
   end process address_decode;

   -- module selection
   we_mem <= sel_mem and we;
   oe_mem <= sel_mem and oe;
   we_vga <= sel_vga and we;
   oe_ps2 <= sel_ps2 and oe;
   
   -- Connect all unused interrupt lines to const '0'
   interrupt(7 downto 2) <= "000000";
   interrupt(0) <= '0';

end;