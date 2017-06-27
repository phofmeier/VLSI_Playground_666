----------------------------------------------------------------------------------
-- Engineer:       Nicholas Feix
--
-- Create Date:    15:30:06 06/26/2017
-- Design Name:
-- Module Name:    address_gen - Behavioral
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_arith.all;

use work.fontROM.all;


entity vga_character_rows is
   port( char_ascii     : in std_logic_vector(7 downto 0);
         char_row       : in std_logic_vector(3 downto 0);
         pixel_row      : out std_logic_vector(7 downto 0) );
end vga_character_rows;

architecture Behavioral of vga_character_rows is

begin

   pixel_row <= fontROM(conv_integer(char_row & char_ascii));

end Behavioral;

