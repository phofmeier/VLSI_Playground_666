----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:27:00 06/12/2017 
-- Design Name: 
-- Module Name:    read_address_generation - Behavioral 
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



-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity read_address_generation is
	port		(pixel_clk    : in std_logic;
				 address_read : out std_logic_vector (11 downto 0);
				 char	        : out std_logic;
				 height       : out std_logic_vector(3 downto 0);
				 pixel_en     : in std_logic;
				 pixel_top    : in std_logic;
				 pixel_left   : in std_logic);
end read_address_generation;

architecture Behavioral of read_address_generation is

signal char_1         : std_logic:= '1';
signal height_1       : std_logic_vector(3 downto 0) := x"0";
signal column         : integer :=0;
signal character_count: integer :=1; 
signal addr_temp      : std_logic_vector( 11 downto 0) ;--:= x"000";

begin

process(pixel_clk,pixel_en, pixel_top, pixel_left)
begin
if (rising_edge(pixel_clk))  then 
	if (pixel_en = '1') then	
		if (column = 8) then
			column <= 1;
			if (char_1 = '1') then 
				char_1 <= '0';
				char<= '0';
			else 
				char_1 <= '1';
				char<= '1';
			end if;

			if (character_count = 80) then 
				character_count<= 1;
			else
				character_count<= character_count+1;
			end if;
		else
			column<= column+1;
		end if;
	else
		char_1 <='1';
		column <= 0;
		char   <= '0';
		character_count <= 1;
	end if;
end if;
end process;

process(pixel_en)
begin
	if (falling_edge(pixel_en)) then
		if (height_1 = "1011") then
			height_1 <= "0000" ;
		else  
			height_1 <= height_1 +1;
		end if;
	end if;
end process;

process(pixel_clk,height_1)
begin
	height<= height_1;
end process;

process(pixel_left, pixel_top, height_1, column, character_count, char_1)
begin
		if ((pixel_left = '1') and (pixel_top ='1')) then
			addr_temp <= x"000"; 
		elsif ((pixel_left ='1')  and (height_1 /="0000")) then
			addr_temp<= addr_temp - x"027"; 
		elsif ((pixel_left ='1')  and (height_1 ="0000") and (pixel_top /='1')) then
			addr_temp<= addr_temp + x"001";		
		elsif((column = 1) and (character_count /= 1) and(char_1 = '0')) then
			addr_temp<= addr_temp + x"001";
		end if;
end process;


process(addr_temp)
begin
	address_read<= addr_temp;
end process;
		
end Behavioral;

