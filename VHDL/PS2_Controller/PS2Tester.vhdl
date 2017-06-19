library ieee;
use ieee.std_logic_1164.all;

entity PS2Tester is
  
  port (
    PS2clk  : out std_logic;
    PS2data : out std_logic;
	 OE		: out std_logic);

end PS2Tester;


architecture behavior of PS2Tester is
--Input codes from PS2-Keyboard
constant key_1 : std_logic_vector(7 downto 0) := "00010110";
constant key_2 : std_logic_vector(7 downto 0) := "00011110";
constant key_3 : std_logic_vector(7 downto 0) := "00100110";
constant key_4 : std_logic_vector(7 downto 0) := "00100101";
constant key_5 : std_logic_vector(7 downto 0) := "00101110";
constant key_6 : std_logic_vector(7 downto 0) := "00110110";
constant key_7 : std_logic_vector(7 downto 0) := "00111101";
constant key_8 : std_logic_vector(7 downto 0) := "00111110";
constant key_9 : std_logic_vector(7 downto 0) := "01000110";
constant key_0 : std_logic_vector(7 downto 0) := "01000101";
constant key_add : std_logic_vector(7 downto 0) := "01111001";
constant key_sub : std_logic_vector(7 downto 0) := "01111011";
constant key_mul : std_logic_vector(7 downto 0) := "01111100";
constant key_div : std_logic_vector(7 downto 0) := "01001010";

  procedure writePS2Data (
    signal   clk   : out std_logic;
    signal   data  : out std_logic;
    constant value : in  std_logic_vector(7 downto 0));

  -- purpose: function to write out serial data in PS2 format
  procedure writePS2Data (
    signal   clk   : out std_logic;
    signal   data  : out std_logic;
    constant value : in  std_logic_vector(7 downto 0)) is
    variable parity : std_logic := '1';
  begin  -- writePS2Data
    -- write start bit
    data <= '0';
    clk  <= '1';
    wait for 15 us;
    clk  <= '0';
    wait for 15 us;
    -- write data
    for i in 0 to 7 loop
      data <= value(i);
      clk  <= '1';
      parity := parity xor value(i);
      wait for 15 us;
      clk <= '0';
      wait for 15 us;
    end loop;  -- i
    -- write parity bit
    data <= parity;
    clk  <= '1';
    wait for 15 us;
    clk  <= '0';
    wait for 15 us;
    -- write stop bit
    data <= '1';
    clk  <= '1';
    wait for 15 us;
    clk  <= '0';
    wait for 15 us;
    clk  <= '1';
  end writePS2Data;

begin  -- behavior

  -- purpose: write out PS2 data
  -- type   : combinational
  -- inputs : 
  -- outputs: PS2data, PS2clk
  writeData: process
  begin  -- process writeData
    -- init clock and data to '1'
    PS2clk <= '1';
    PS2data <= '1';
	 OE <= '1';

    ---------------------------------------------------------------------------
    -- If different / more scancodes are required, change or add additional
    -- blocks to write PS2 data
    ---------------------------------------------------------------------------

    -- wait for other components to init
    wait for 2 ms;

    -- key "Keypad 3" press 
    writePS2Data(PS2clk, PS2data, key_1);
    wait for 1 ms;
	 OE <= '0';
	 wait for 2 us;
	 OE <= '1';
    -- key "Keypad 3" release
    writePS2Data(PS2clk, PS2data, key_2);
    wait for 40 us;
	 OE <= '0';
	 wait for 2 us;
	 OE <= '1';
    writePS2Data(PS2clk, PS2data, key_3);


    -- wait before next "Keystroke"
    wait for 1 ms;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    -- key "Keypad 4" press 
    writePS2Data(PS2clk, PS2data, key_4);
    wait for 1 ms;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    -- key "Keypad 4" release    
    writePS2Data(PS2clk, PS2data, key_5);
    wait for 40 us;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    writePS2Data(PS2clk, PS2data, key_6);

    -- wait before next "Keystroke"    
    wait for 1 ms;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    -- key "Keypad *" press and release    
    writePS2Data(PS2clk, PS2data, key_7);
    wait for 1 ms;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    -- key "Keypad *" release    
    writePS2Data(PS2clk, PS2data, key_8);
    wait for 40 us;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    writePS2Data(PS2clk, PS2data, key_9);

    -- wait before next "Keystroke"
    wait for 1 ms;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';

    -- key "Keypad 7" press
    writePS2Data(PS2clk, PS2data, key_0);
    wait for 1 ms;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    -- key "Keypad 7" release    
    writePS2Data(PS2clk, PS2data, key_add);
    wait for 40 us;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    writePS2Data(PS2clk, PS2data, key_sub);

    -- wait before next "Keystroke"
    wait for 1 ms;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';

    -- key "Keypad /" press 
    writePS2Data(PS2clk, PS2data, key_mul);
    wait for 40 us;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    writePS2Data(PS2clk, PS2data, key_div);
    wait for 1 ms;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    -- key "Keypad /" release    
    writePS2Data(PS2clk, PS2data, X"E0");
    wait for 40 us;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    writePS2Data(PS2clk, PS2data, X"F0");
    wait for 40 us;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    writePS2Data(PS2clk, PS2data, X"4A");

    -- wait before next "Keystroke"
    wait for 1 ms;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';

    -- key "Keypad 2" press 
    writePS2Data(PS2clk, PS2data, X"72");
    wait for 1 ms;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    -- key "Keypad 2" release    
    writePS2Data(PS2clk, PS2data, X"F0");
    wait for 40 us;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    writePS2Data(PS2clk, PS2data, X"72");

    -- wait before next "Keystroke"    
    wait for 1 ms;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';

    -- key "Keypad ENTER" press 
    writePS2Data(PS2clk, PS2data, X"E0");
    wait for 40 us;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    writePS2Data(PS2clk, PS2data, X"5A");
    wait for 1 ms;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    -- key "Keypad ENTER" release    
    writePS2Data(PS2clk, PS2data, X"E0");
    wait for 40 us;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    writePS2Data(PS2clk, PS2data, X"F0");
    wait for 40 us;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    writePS2Data(PS2clk, PS2data, X"5A");

    -- wait before next "Keystroke"    
    wait for 1 ms;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    -- key "Keypad 8" press    
    writePS2Data(PS2clk, PS2data, X"75");
    wait for 1 ms;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    -- key "Keypad 8" release    
    writePS2Data(PS2clk, PS2data, X"F0");
    wait for 40 us;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    writePS2Data(PS2clk, PS2data, X"75");

    -- wait before next "Keystroke"    
    wait for 1 ms;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    -- key "Keypad 4" press    
    writePS2Data(PS2clk, PS2data, X"6B");
    wait for 1 ms;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    -- key "Keypad 4" release    
    writePS2Data(PS2clk, PS2data, X"F0");
    wait for 40 us;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    writePS2Data(PS2clk, PS2data, X"6B");

    -- wait before next "Keystroke"    
    wait for 1 ms;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    -- key "Keypad -" press    
    writePS2Data(PS2clk, PS2data, X"7B");
    wait for 1 ms;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    -- key "Keypad -" release    
    writePS2Data(PS2clk, PS2data, X"F0");
    wait for 40 us;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    writePS2Data(PS2clk, PS2data, X"7B");

    -- wait before next "Keystroke"    
    wait for 1 ms;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    -- key "Keypad 1" press    
    writePS2Data(PS2clk, PS2data, X"69");
    wait for 1 ms;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    -- key "Keypad 1" release    
    writePS2Data(PS2clk, PS2data, X"F0");
    wait for 40 us;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    writePS2Data(PS2clk, PS2data, X"69");

    -- wait before next "Keystroke"    
    wait for 1 ms;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';

    -- key "Keypad ENTER" press    
    writePS2Data(PS2clk, PS2data, X"E0");
    wait for 40 us;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    writePS2Data(PS2clk, PS2data, X"5A");
    wait for 1 ms;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    -- key "Keypad ENTER" release    
    writePS2Data(PS2clk, PS2data, X"E0");
    wait for 40 us;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    writePS2Data(PS2clk, PS2data, X"F0");
    wait for 40 us;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    writePS2Data(PS2clk, PS2data, X"5A");

    -- wait before next "Keystroke"    
    wait for 1 ms;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';

    -- key "Keypad 1" press    
    writePS2Data(PS2clk, PS2data, X"69");
    wait for 1 ms;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    -- key "Keypad 1" release    
    writePS2Data(PS2clk, PS2data, X"F0");
    wait for 40 us;
	 OE <= '0';
	 wait for 20 ns;
	 OE <= '1';
    writePS2Data(PS2clk, PS2data, X"69");


    -- wait forever
    wait;
    
    
    
  end process writeData;

    

end behavior;

-----------------------------------------------------------------------
-- Clockgenerator
-----------------------------------------------------------------------

-- description of clock/reset generation entity
library IEEE;
use IEEE.std_logic_1164.all;
entity clk_gen is
    port ( clk : out std_logic	;
				  reset : out std_logic );
end clk_gen;

architecture clock of clk_gen is
	begin

	reset_driver : 
		reset <= '0', '1' after 30 ns ;

	clock_driver : process     
   variable tmp_clk : std_logic := '1';
   	begin	
    		tmp_clk := not tmp_clk;
    		clk	<= tmp_clk;
  		wait for 10 ns;
   end process clock_driver;
end clock ;


library IEEE;
use IEEE.std_logic_1164.all;
entity testbench is
end testbench;

-- wireing of testbench
use work.all;
architecture structural of testbench is

	signal	PS2clk, PS2data, clk, reset, OE : std_logic ;
	signal	output : STD_LOGIC_VECTOR (7 downto 0);

component clk_gen
	  port (	clk  : out std_logic ;
				reset : out std_logic);
end component;

component PS2Tester
port (	PS2clk  : out std_logic;
			PS2data : out std_logic;
			OE 	  : out std_logic);
end component;

component PS2_Controller
port ( 	  OE	: in std_logic;
			  databus : out  STD_LOGIC_VECTOR (7 downto 0);
           interrupt : out  STD_LOGIC;
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           PS2clk : in  STD_LOGIC;
           PS2data : in  STD_LOGIC );
end component;

begin
	clockgen: clk_gen port map(	
		clk => clk ,
		reset => reset);

	PS2Tester1: PS2Tester port map(
		PS2clk => PS2clk ,
		PS2data => PS2data,
		OE => OE);
		
	PS2_Controller1: PS2_Controller port map(
		clk => clk ,
		reset => reset,
		PS2clk => PS2clk ,
		PS2data => PS2data ,
		databus => output,
		OE => OE);
		

end structural;
