----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:12:48 06/20/2017 
-- Design Name: 
-- Module Name:    image_gen - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity image_gen is
	port( pixel_en   : in std_logic;
			clk		  : in std_logic;
			pixel_clk  : in std_logic;
			red        : out std_logic;
			blue		  : out std_logic;
			green      : out std_logic;
			pixel      : in std_logic);
			
end image_gen;

architecture Behavioral of image_gen is
begin
process (pixel_en, pixel_clk,pixel)
begin
	if(rising_edge(pixel_clk)) then
	if (pixel_en ='1' and pixel ='1') then
		red  <= pixel;
		blue <='0';
		green<='0';
	elsif (pixel_en ='1' and pixel /='1') then
		red  <='0';
		blue <='1';
		green<='1';
	else
		red  <='0';
		blue <='0';
		green<='0';
	end if;
end if;
end process;

end Behavioral;
	

