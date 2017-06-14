----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:28:56 06/09/2017 
-- Design Name: 
-- Module Name:    testbench - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.sim_bmppack.all;
use work.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all


entity testbench is
end testbench;

architecture behavioral of testbench is


component timing_module is
     
 port(clk : in std_logic;
		reset: in std_logic;
           hsync : out std_logic;
           vsync : out std_logic;
           red : out std_logic;
           green : out std_logic;
           blue : out std_logic);
    end component;

component vgaTesterDigInterface
port (
vsync : in std_logic;
hsync : in std_logic;
red : in std_logic;
green : in std_logic;
blue : in std_logic);
end component;

  


signal hsync,vsync,red,green,blue,clk,reset: std_logic;


begin

    uut: timing_module port map(
	 clk=>clk,
	 reset=> reset,
		hsync => hsync,
       vsync=> vsync ,
        red=> red,
        green => green  ,
        blue =>  blue 
             );
	uu2: vgaTesterDigInterface port map(
       vsync =>  vsync ,
       hsync=> hsync,
		 red => red,
		green =>green,
		blue =>blue
		 );
  
	reset_driver : 
		reset <= '1', '0' after 30 ns ;

	clock_driver : process     
   variable tmp_clk : std_logic := '1';
   	begin	
    		tmp_clk := not tmp_clk;
    		clk	<= tmp_clk;
  		wait for 10 ns;
   end process clock_driver;
end behavioral; 

