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
   port ( clk  : in  std_logic;
          addr : in  std_logic_vector (10 downto 0);
          inp  : in  std_logic_vector (15 downto 0);
          outp : out std_logic_vector (15 downto 0);
          we   : in  std_logic);
end memory_int;


architecture Simulation of memory_int is
   type saveArray is array (0 to (2**addr'length-1)) of std_logic_vector(15 downto 0);
   signal data : saveArray := (others => (others => '0'));
begin

   mem_ctrl: process(clk)
      variable init : integer := 0;
      file inputfile : text open read_mode is "../memory.txt";
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
         if we = '1' then
            data(conv_integer(unsigned(addr))) <= inp;
            outp <= inp;
         else
            outp <= data(conv_integer(unsigned(addr)));
         end if;
      end if;
   end process mem_ctrl;
end Simulation;


architecture Synthesis of memory_int is
   type saveArray is array (0 to (2**addr'length-1)) of std_logic_vector(15 downto 0);
   signal data : saveArray := (
      X"c008",
      X"a200",
      X"a200",
      X"a200",
      X"a200",
      X"a200",
      X"a200",
      X"a200",
      X"8020",
      X"b000",
      X"801c",
      X"b005",
      X"9022",
      X"8021",
      X"b003",
      X"801e",
      X"9fff",
      X"f018",
      X"8022",
      X"101d",
      X"9022",
      X"b023",
      X"9fff",
      X"c011",
      X"8fff",
      X"301f",
      X"d018",
      X"a100",
      X"0000",
      X"0001",
      X"000f",
      X"e000",
      X"0600",
      X"0800",
      X"0000",
      others => X"0000" );
begin

   mem_ctrl: process(clk)
   begin
      if rising_edge(clk) then
         if we = '1' then
            data(conv_integer(unsigned(addr))) <= inp;
            outp <= inp;
         else
            outp <= data(conv_integer(unsigned(addr)));
         end if;
      end if;
   end process mem_ctrl;
end Synthesis;







