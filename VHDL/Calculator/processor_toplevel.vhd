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
			--PS-2 Input
			ps2clk		: in std_logic;
			ps2data		: in std_logic;
         -- outputs to LEDs
         leds        : out std_logic_vector( 7 downto 0) );
end processor_toplevel;

use work.all;

architecture Behavioral of processor_toplevel is

   signal oe         : std_logic;
   signal we         : std_logic;
	signal oe_ps2		: std_logic;
   signal oe_test    : std_logic;
   signal we_test    : std_logic;
   signal oe_mem     : std_logic;
   signal we_mem     : std_logic;
   signal addressbus : std_logic_vector (11 downto 0) := (others => '0');
   signal databus    : std_logic_vector (15 downto 0) := (others => '0');
   signal interrupt  : std_logic_vector (7 downto 0)  := (others => '0');

   signal sel_mem    : std_logic;
   signal sel_test   : std_logic;
	signal sel_ps2		: std_logic;

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
	
	ps2: entity PS2_Controller
	port map(
		clk      => clk,
		OE			=> oe_ps2,
		databus  => databus,
		interrupt => interrupt(1),
		reset    => reset,
		PS2clk   => ps2clk,
      PS2data  => ps2data
	);

--   test: entity test_module
--   port map(
--      clk => clk,
--      reset => reset,
--      dataIO => databus,
--      we => we_test,
--      oe => oe_test
--   );

   -- address decoding
   sel_mem  <= '1' when addressBus(11) = '0' else '0';
   --sel_test <= '1' when addressBus(11) = '1' else '0';
	sel_ps2	<= '1' when addressBus = X"FFF" else '0';
	sel_test <= '1' when addressBus = X"FFE" else '0';

   -- module selection
   we_mem   <= sel_mem  and we;
   oe_mem   <= sel_mem  and oe;
   we_test  <= sel_test and we;
   oe_test  <= sel_test and oe;
	oe_ps2	<= sel_ps2 	and oe;

   -- interrupts but int1 currently not used
   --interrupt <= "000000" & interrupt1 & '0';

end;