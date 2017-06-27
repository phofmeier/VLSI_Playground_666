----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:23:44 06/16/2017 
-- Design Name: 
-- Module Name:    char_buffer - Behavioral 
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

entity char_buffer is
				port(dataout  : in STD_LOGIC_VECTOR (15 downto 0);
					  pixel_clk: in STD_LOGIC;
		           char     : in STD_LOGIC;
					  height   : in STD_LOGIC_VECTOR(3 downto 0);
					  data_font: out STD_LOGIC_VECTOR(11 downto 0));
end char_buffer;

architecture Behavioral of char_buffer is

signal data : std_logic_vector(7 downto 0) := "00000000";

begin
process(dataout,char)
begin
	if (char = '0') then 
		data <= dataout(7 downto 0);
	else 
		data <= dataout(15 downto 8);
	end if;
end process;

process(data)
begin
		data_font<= height & data;
end process;

end Behavioral;

