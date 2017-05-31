----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    17:42:44 01/08/2008
-- Design Name:
-- Module Name:    memory_int - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.std_logic_textio.all;
use std.textio.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity memory_int is
    Port ( clk : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (10 downto 0);
           inp : in  STD_LOGIC_VECTOR (15 downto 0);
           outp : out  STD_LOGIC_VECTOR (15 downto 0);
           wren : in  STD_LOGIC);
end memory_int;

architecture Behavioral of memory_int is
	type saveArray is array (0 to (2**addr'length-1)) of std_logic_vector(15 downto 0);
	signal data : saveArray := (
		  X"805f",
		  X"9fff",
		  X"8fff",
		  X"305a",
		  X"d002",
		  X"805e",
		  X"906b",
		  X"106c",
		  X"9fff",
		  X"8fff",
		  X"305a",
		  X"d009",
		  X"8065",
		  X"2066",
		  X"9fff",
		  X"8fff",
		  X"305a",
		  X"d00f",
		  X"8068",
		  X"4000",
		  X"9fff",
		  X"8fff",
		  X"305a",
		  X"d015",
		  X"8068",
		  X"5000",
		  X"9fff",
		  X"8fff",
		  X"305a",
		  X"d01b",
		  X"8069",
		  X"6000",
		  X"4000",
		  X"d023",
		  X"c059",
		  X"8067",
		  X"9fff",
		  X"8fff",
		  X"305a",
		  X"d025",
		  X"8065",
		  X"e059",
		  X"8069",
		  X"e02d",
		  X"c059",
		  X"806a",
		  X"9fff",
		  X"8fff",
		  X"305a",
		  X"d02f",
		  X"c033",
		  X"8fff",
		  X"906d",
		  X"305b",
		  X"d03c",
		  X"806b",
		  X"105e",
		  X"305e",
		  X"906b",
		  X"c055",
		  X"806d",
		  X"305c",
		  X"d049",
		  X"806c",
		  X"106c",
		  X"906c",
		  X"3064",
		  X"d055",
		  X"806c",
		  X"3060",
		  X"1062",
		  X"906c",
		  X"c055",
		  X"806d",
		  X"305d",
		  X"d033",
		  X"806c",
		  X"7000",
		  X"906c",
		  X"3061",
		  X"d055",
		  X"806c",
		  X"3060",
		  X"1063",
		  X"906c",
		  X"806b",
		  X"106c",
		  X"9fff",
		  X"c033",
		  X"c059",
		  X"e000",
		  X"8000",
		  X"4000",
		  X"2000",
		  X"8100",
		  X"00ff",
		  X"007e",
		  X"0001",
		  X"0002",
		  X"0040",
		  X"0080",
		  X"000a",
		  X"0009",
		  X"0004",
		  X"fffd",
		  X"ffff",
		  X"0005",
		  X"0000",
		  X"0018",
		  X"0000",
		  others => X"0000" );
begin

	mem_ctrl: process(clk)
	begin
	   if rising_edge(clk) then
			if wren = '1' then
				data(conv_integer(unsigned(addr))) <= inp;
				outp <= inp;
			else
				outp <= data(conv_integer(unsigned(addr)));
			end if;
		end if;
	end process mem_ctrl;
end Behavioral;







