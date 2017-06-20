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
      X"c0a1",
      X"a200",
      X"a200",
      X"a200",
      X"a200",
      X"a200",
      X"a200",
      X"80ab",
      X"b000",
      X"80ac",
      X"b005",
      X"80b2",
      X"9fff",
      X"8fff",
      X"30ad",
      X"d00e",
      X"80b1",
      X"90c8",
      X"10c9",
      X"9fff",
      X"f09d",
      X"80b9",
      X"20ba",
      X"9fff",
      X"f09d",
      X"80bc",
      X"4000",
      X"9fff",
      X"f09d",
      X"80bc",
      X"5000",
      X"9fff",
      X"f09d",
      X"80bd",
      X"6000",
      X"4000",
      X"d027",
      X"c09c",
      X"80bb",
      X"9fff",
      X"f09d",
      X"80b9",
      X"e09c",
      X"80bd",
      X"e02f",
      X"c09c",
      X"80c0",
      X"9fff",
      X"f09d",
      X"80b9",
      X"b001",
      X"a001",
      X"20bb",
      X"9fff",
      X"f09d",
      X"80d0",
      X"b002",
      X"80b9",
      X"b012",
      X"80c2",
      X"a012",
      X"20c2",
      X"9fff",
      X"f09d",
      X"80d1",
      X"b002",
      X"80b9",
      X"b022",
      X"80ba",
      X"b022",
      X"80c0",
      X"b022",
      X"80d1",
      X"b002",
      X"a022",
      X"90cb",
      X"a022",
      X"10cb",
      X"90cb",
      X"a022",
      X"10cb",
      X"90cb",
      X"20c6",
      X"9fff",
      X"f09d",
      X"80d2",
      X"10c4",
      X"b003",
      X"80c3",
      X"b033",
      X"80c0",
      X"b033",
      X"80ba",
      X"b033",
      X"80d2",
      X"10c4",
      X"b003",
      X"a033",
      X"90cb",
      X"a033",
      X"10cb",
      X"90cb",
      X"a033",
      X"10cb",
      X"90cb",
      X"20c5",
      X"9fff",
      X"f09d",
      X"80be",
      X"10b9",
      X"a004",
      X"30b4",
      X"d09c",
      X"80b9",
      X"9fff",
      X"f09d",
      X"c076",
      X"8fff",
      X"90ca",
      X"30ae",
      X"d07f",
      X"80c8",
      X"10b1",
      X"30b1",
      X"90c8",
      X"c098",
      X"80ca",
      X"30af",
      X"d08c",
      X"80c9",
      X"10c9",
      X"90c9",
      X"30b8",
      X"d098",
      X"80c9",
      X"30b3",
      X"10b6",
      X"90c9",
      X"c098",
      X"80ca",
      X"30b0",
      X"d076",
      X"80c9",
      X"7000",
      X"90c9",
      X"30b5",
      X"d098",
      X"80c9",
      X"30b3",
      X"10b7",
      X"90c9",
      X"80c8",
      X"10c9",
      X"9fff",
      X"c076",
      X"c09c",
      X"8fff",
      X"30ad",
      X"d09d",
      X"a100",
      X"90cf",
      X"a006",
      X"20c1",
      X"d0a6",
      X"c09c",
      X"80bf",
      X"9fff",
      X"f09d",
      X"80cf",
      X"a200",
      X"07ff",
      X"0102",
      X"e000",
      X"8000",
      X"4000",
      X"2000",
      X"8100",
      X"00ff",
      X"007e",
      X"0008",
      X"0001",
      X"0002",
      X"0040",
      X"0080",
      X"000a",
      X"0009",
      X"0004",
      X"fffd",
      X"ffff",
      X"7fff",
      X"00aa",
      X"0005",
      X"0002",
      X"0003",
      X"0006",
      X"0001",
      X"000b",
      X"0010",
      X"00b9",
      X"0000",
      X"0018",
      X"0000",
      X"0000",
      X"0000",
      X"0000",
      X"0000",
      X"0000",
      X"00cb",
      X"00cc",
      X"00ce",
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







