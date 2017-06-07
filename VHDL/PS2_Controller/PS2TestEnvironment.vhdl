-------------------------------------------------------------------------------
-- PS2TestEnvironment
--
-- A design which receives PS2 scancodes and outputs them to the LCD display 
-- on the evaluation board.
-------------------------------------------------------------------------------

library ieee;
use ieee.Std_Logic_1164.all;

entity PS2TestEnvironment is
  
  port (
    clk     : in std_logic;
    reset   : in std_logic;
    ps2clk  : in std_logic;
    ps2data : in std_logic;
    lcdData : out std_logic_vector(3 downto 0);
    lcdRS   : out std_logic;
    lcdRW   : out std_logic;
    lcdE    : out std_logic;
    sf_ce0  : out std_logic );

end PS2TestEnvironment;


architecture structural  of PS2TestEnvironment is

  -----------------------------------------------------------------------------
  -- TODO: insert yout PS2 interface here instead of the component
  --       ps2interface
  -----------------------------------------------------------------------------  
  component PS2_Controller
    port (
      clk           : in  std_logic;
      reset         : in  std_logic;
      PS2clk        : in  std_logic;
      PS2data       : in  std_logic;
      interrupt 	  : out std_logic;
      databus       : out std_logic_vector(7 downto 0));
  end component;

  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------

  
  component byteToDisplay
    port (
      clk      : in  std_logic;
      reset    : in  std_logic;
      dispData : in  std_logic_vector(7 downto 0);
      dispReq  : in  std_logic;
      lcdData  : out std_logic_vector(3 downto 0);
      lcdRS    : out std_logic;
      lcdRW    : out std_logic;
      lcdE     : out std_logic);
  end component;

  signal data : std_logic_vector(7 downto 0);
  signal dataAvailable : std_logic;

  signal resetB : std_logic;

begin  -- structural

  -----------------------------------------------------------------------------
  -- TODO: instatiate your PS2 interface here instead of the component
  --       ps2interface
  -----------------------------------------------------------------------------

  PS2_Controller_inst: PS2_Controller
    port map (
      clk           => clk,
      reset         => reset,
      PS2clk        => ps2clk,
      PS2data       => ps2data,
      interrupt 	  => dataAvailable,
      databus       => data);

  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------

  
  byteToDisplay_inst: byteToDisplay
    port map (
      clk      => clk,
      reset    => resetB,
      dispData => data,
      dispReq  => dataAvailable,
      lcdData  => lcdData,
      lcdRS    => lcdRS,
      lcdRW    => lcdRW,
      lcdE     => lcdE);

  -- switch off enable of Strata flash chip on the evaluation board, which is
  -- connected to the same control lines as the LCD
  sf_ce0 <= '1';

  -- active-low reset signal for byteToDisplay component
  resetB <= not reset;
  

end structural ;
