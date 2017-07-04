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


entity processor_toplevel is
   port( reset       : in std_logic;
         clk         : in std_logic;
         -- interrupt input from switch 1
         interrupt1  : in std_logic;
         -- inputs from the rotary knob
         rot_a       : in std_logic;
         rot_b       : in std_logic;
         rot_btn     : in std_logic;
         -- outputs to LEDs
         leds        : out std_logic_vector( 7 downto 0);
         -- VGA IO pins
         hsync       : out std_logic;
         vsync       : out std_logic;
         red         : out std_logic;
         green       : out std_logic;
         blue        : out std_logic );
end processor_toplevel;

use work.all;

architecture Behavioral of processor_toplevel is

   signal oe         : std_logic;
   signal we         : std_logic;
   signal oe_test    : std_logic;
   signal we_test    : std_logic;
   signal oe_mem     : std_logic;
   signal we_mem     : std_logic;
   signal we_vga     : std_logic;
   signal addressbus : std_logic_vector (11 downto 0) := (others => '0');
   signal databus    : std_logic_vector (15 downto 0) := (others => '0');
   signal interrupt  : std_logic_vector (7 downto 0)  := (others => '0');

   -- signal addr_vga   : unsigned(11 downto 0);

   signal sel_mem    : std_logic;
   signal sel_test   : std_logic;
   signal sel_vga    : std_logic;

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

   test: entity debug_module
   port map(
      clk      => clk,
      rst      => reset,
      dataIO   => databus,
      we       => we_test,
      oe       => oe_test,
      rot_a    => rot_a,
      rot_b    => rot_b,
      rot_btn  => rot_btn,
      leds     => leds
   );

   vga_unit: entity vga_controller(Synthesis)
   port map (
      clk         => clk,
      reset       => reset,
      -- addressbus  => std_logic_vector(addr_vga(10 downto 0)),
      addressbus  => addressbus(10 downto 0),
      dataIN      => databus,
      we          => we_vga,
      hsync       => hsync,
      vsync       => vsync,
      red         => red,
      green       => green,
      blue        => blue
   );

   -- address decoding
address_decode: process(addressbus)
begin
   sel_mem  <= '0';
   sel_test <= '0';
   sel_vga  <= '0';
   -- addr_vga <= x"000";

   if ( addressbus(11) = '0' ) then
      sel_mem <= '1';
   elsif ( addressbus = x"FFF" ) then
      sel_test <= '1';
   else
      sel_vga <= '1';
   end if;
end process address_decode;

   -- module selection
   we_mem   <= sel_mem  and we;
   oe_mem   <= sel_mem  and oe;
   we_test  <= sel_test and we;
   oe_test  <= sel_test and oe;
   we_vga   <= sel_vga  and we;

   -- interrupts but int1 currently not used
   interrupt <= "000000" & interrupt1 & '0';

end;