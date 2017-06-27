----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:30:25 06/11/2017 
-- Design Name: 
-- Module Name:    address_mux - Behavioral 
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

entity address_mux is
    Port ( addressbus : in  STD_LOGIC_VECTOR (11 downto 0);
           we         : in  STD_LOGIC;
			  pixel_en   : in  STD_LOGIC;
			  pixel_clk  : in STD_LOGIC;
           address_read : in  STD_LOGIC_VECTOR (11 downto 0);
           address      : out  STD_LOGIC_VECTOR(11 downto 0));
end address_mux;

architecture Behavioral of address_mux is

begin

process(addressbus,address_read,pixel_en)
	begin
		if(pixel_en ='1') then
			address<= address_read;
		elsif(we = '1') then 
			address <= addressbus;
		end if;
end process;

end Behavioral;


