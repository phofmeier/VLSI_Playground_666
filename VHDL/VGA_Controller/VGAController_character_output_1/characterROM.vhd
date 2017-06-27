----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:31:48 06/16/2017 
-- Design Name: 
-- Module Name:    characterROM - Behavioral 
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
use IEEE.STD_LOGIC_unsigned.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_arith.all;

use work.fontROM.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity characterROM is
		port( 
				pixel_clk: in std_logic;
				pixel_en : in std_logic;
		      data_font: in std_logic_vector(11 downto 0);
				pixel    : out std_logic);
end characterROM;

architecture Behavioral of characterROM is

signal count: integer := 0;
signal pixelLineNow : std_logic_vector(7 downto 0);
signal pixelLineNow_signal : std_logic_vector(7 downto 0);
begin

process(data_font,pixel_en)
begin
	if((pixel_en = '1')) then
		pixelLineNow<= fontROM(conv_integer(data_font));
	else 
		pixelLineNow<="00000000";
	end if;
end process;

Process(pixel_clk,data_font) 
begin
	if falling_edge(pixel_clk) then
		pixelLineNow_signal <= pixelLineNow;
		if(pixelLineNow_signal /= pixelLineNow or count=7) then
			count <= 0;
			pixel<=pixelLineNow(0);  				
			elsif ( count < 7 ) then
				pixel <= (pixelLineNow(count+1));
				count <= count +1;
			else 
			count <= 0;
		end if;
	end if;
end process;

end Behavioral;

