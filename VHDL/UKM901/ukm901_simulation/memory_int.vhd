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
	signal data : saveArray := (others => "0000000000000000");
begin

	mem_ctrl: process(clk)
		variable init : integer := 0;
		file inputfile : text open read_mode is "memory.txt";
		variable inputline : line;
		variable inputval  : std_logic_vector(15 downto 0);
		variable address   : integer := 0;
		
	begin
	   if init = 0 then
			while not endfile(inputfile) loop
				readline(inputfile, inputline);
				hread(inputline, inputval);
				data(address) <= inputval;
				address := address+1;
			end loop;
			init := 1;
		elsif rising_edge(clk) then
			if wren = '1' then
				data(conv_integer(unsigned(addr))) <= inp;
				outp <= inp;
			else
				outp <= data(conv_integer(unsigned(addr)));
			end if;
		end if;
	end process mem_ctrl;
end Behavioral;







