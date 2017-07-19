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
   signal data : saveArray := ( X"c008",
  X"c21d",
  X"a200",
  X"a200",
  X"a200",
  X"a200",
  X"a200",
  X"a200",
  X"822b",
  X"b000",
  X"822c",
  X"b005",
  X"828e",
  X"b001",
  X"8224",
  X"9276",
  X"8222",
  X"9273",
  X"9274",
  X"9275",
  X"9276",
  X"9277",
  X"9278",
  X"9279",
  X"927a",
  X"927b",
  X"927c",
  X"927d",
  X"f162",
  X"8273",
  X"d01d",
  X"f023",
  X"8222",
  X"9273",
  X"c01d",
  X"8276",
  X"d041",
  X"8273",
  X"222f",
  X"d04c",
  X"8273",
  X"2230",
  X"d04f",
  X"8273",
  X"2231",
  X"d058",
  X"8273",
  X"223e",
  X"d05b",
  X"8273",
  X"2233",
  X"d07e",
  X"8273",
  X"223f",
  X"d095",
  X"8276",
  X"2223",
  X"d04b",
  X"8273",
  X"2234",
  X"e04b",
  X"823d",
  X"2273",
  X"e04b",
  X"c084",
  X"8273",
  X"2232",
  X"d06b",
  X"8273",
  X"2234",
  X"e04b",
  X"823d",
  X"2273",
  X"e04b",
  X"c084",
  X"a100",
  X"8222",
  X"9274",
  X"c052",
  X"8223",
  X"9274",
  X"c052",
  X"8222",
  X"9276",
  X"f0cc",
  X"8274",
  X"927a",
  X"c0a7",
  X"8223",
  X"9275",
  X"c05d",
  X"8224",
  X"9275",
  X"8222",
  X"9276",
  X"827b",
  X"d064",
  X"f0c1",
  X"8280",
  X"c065",
  X"8277",
  X"9279",
  X"8222",
  X"9277",
  X"8275",
  X"927b",
  X"c0a7",
  X"8222",
  X"9276",
  X"8278",
  X"b021",
  X"8279",
  X"b021",
  X"827a",
  X"b021",
  X"827b",
  X"b021",
  X"8222",
  X"9278",
  X"9279",
  X"927a",
  X"927b",
  X"827c",
  X"1223",
  X"927c",
  X"c0a7",
  X"827c",
  X"d04b",
  X"8223",
  X"9276",
  X"f0e4",
  X"c0a7",
  X"8224",
  X"9276",
  X"8277",
  X"927e",
  X"8225",
  X"927f",
  X"f0f3",
  X"8273",
  X"2234",
  X"1280",
  X"9277",
  X"a004",
  X"322d",
  X"d0a7",
  X"8223",
  X"927d",
  X"c0a7",
  X"827c",
  X"d099",
  X"f0e4",
  X"c095",
  X"f0cc",
  X"8278",
  X"9277",
  X"827d",
  X"d09f",
  X"c0a7",
  X"f17e",
  X"8250",
  X"b002",
  X"f1b0",
  X"f1ce",
  X"f17e",
  X"f1c3",
  X"c0af",
  X"827d",
  X"d0bd",
  X"f17e",
  X"824a",
  X"b002",
  X"f1b0",
  X"f17e",
  X"f1c3",
  X"8222",
  X"9277",
  X"9278",
  X"9279",
  X"927a",
  X"927b",
  X"927c",
  X"927d",
  X"9276",
  X"8224",
  X"9276",
  X"828e",
  X"b001",
  X"a100",
  X"8273",
  X"9283",
  X"f18f",
  X"a100",
  X"8277",
  X"927f",
  X"8279",
  X"927e",
  X"827b",
  X"2223",
  X"d0ca",
  X"f11f",
  X"c0cb",
  X"f0f3",
  X"a100",
  X"827b",
  X"d0d3",
  X"f0c1",
  X"8280",
  X"9277",
  X"8222",
  X"927b",
  X"827a",
  X"d0d9",
  X"8278",
  X"2277",
  X"9278",
  X"c0dc",
  X"8278",
  X"1277",
  X"9278",
  X"a004",
  X"322d",
  X"d0e1",
  X"8223",
  X"927d",
  X"8222",
  X"9277",
  X"a100",
  X"f0cc",
  X"8278",
  X"9277",
  X"a031",
  X"927b",
  X"a031",
  X"927a",
  X"a031",
  X"9279",
  X"a031",
  X"9278",
  X"827c",
  X"2223",
  X"927c",
  X"a100",
  X"8222",
  X"9280",
  X"9281",
  X"827e",
  X"e0f9",
  X"c0fe",
  X"5000",
  X"927e",
  X"8281",
  X"4000",
  X"9281",
  X"827f",
  X"e101",
  X"c106",
  X"5000",
  X"927f",
  X"8281",
  X"4000",
  X"9281",
  X"827f",
  X"d116",
  X"3223",
  X"d10e",
  X"827e",
  X"1280",
  X"e11c",
  X"9280",
  X"827e",
  X"127e",
  X"927e",
  X"e11c",
  X"827f",
  X"7000",
  X"927f",
  X"c107",
  X"8281",
  X"d11b",
  X"8280",
  X"5000",
  X"9280",
  X"a100",
  X"8223",
  X"927d",
  X"a100",
  X"827f",
  X"d15b",
  X"8222",
  X"9280",
  X"9281",
  X"827e",
  X"e127",
  X"c12c",
  X"5000",
  X"927e",
  X"8281",
  X"4000",
  X"9281",
  X"827f",
  X"e12f",
  X"c134",
  X"5000",
  X"927f",
  X"8281",
  X"4000",
  X"9281",
  X"8223",
  X"9282",
  X"827e",
  X"227f",
  X"e140",
  X"827f",
  X"127f",
  X"927f",
  X"8282",
  X"1282",
  X"9282",
  X"c136",
  X"827f",
  X"7000",
  X"927f",
  X"8282",
  X"7000",
  X"9282",
  X"d155",
  X"827e",
  X"227f",
  X"e14e",
  X"927e",
  X"8282",
  X"1280",
  X"9280",
  X"827f",
  X"7000",
  X"927f",
  X"8282",
  X"7000",
  X"9282",
  X"c146",
  X"8281",
  X"d15a",
  X"8280",
  X"5000",
  X"9280",
  X"a100",
  X"f17e",
  X"826d",
  X"b002",
  X"f1b0",
  X"8223",
  X"927d",
  X"a100",
  X"f16b",
  X"f1c3",
  X"8266",
  X"b002",
  X"f1b0",
  X"f17e",
  X"f1c3",
  X"f17e",
  X"a100",
  X"826e",
  X"b003",
  X"826f",
  X"9284",
  X"8241",
  X"b023",
  X"8284",
  X"2223",
  X"9284",
  X"d176",
  X"c16f",
  X"826e",
  X"9285",
  X"b003",
  X"8222",
  X"9286",
  X"8223",
  X"9287",
  X"a100",
  X"8223",
  X"9287",
  X"8222",
  X"9286",
  X"8285",
  X"1270",
  X"9285",
  X"b003",
  X"8271",
  X"2285",
  X"e18a",
  X"a100",
  X"f16b",
  X"826e",
  X"9285",
  X"b003",
  X"a100",
  X"8287",
  X"d1a7",
  X"8283",
  X"6000",
  X"6000",
  X"6000",
  X"6000",
  X"6000",
  X"6000",
  X"6000",
  X"6000",
  X"9288",
  X"3243",
  X"b013",
  X"8222",
  X"9287",
  X"1286",
  X"9286",
  X"8272",
  X"2286",
  X"e1a5",
  X"a100",
  X"f17e",
  X"a100",
  X"8283",
  X"1288",
  X"b023",
  X"8223",
  X"9287",
  X"8223",
  X"1286",
  X"9286",
  X"a100",
  X"a012",
  X"7000",
  X"7000",
  X"7000",
  X"7000",
  X"7000",
  X"7000",
  X"7000",
  X"7000",
  X"d1c2",
  X"9283",
  X"f18f",
  X"a022",
  X"3245",
  X"d1c2",
  X"9283",
  X"f18f",
  X"c1b0",
  X"a100",
  X"8270",
  X"9284",
  X"8240",
  X"b023",
  X"8284",
  X"2223",
  X"9284",
  X"d1cc",
  X"c1c5",
  X"f17e",
  X"a100",
  X"8222",
  X"9289",
  X"928a",
  X"928b",
  X"928c",
  X"928d",
  X"8277",
  X"e216",
  X"8277",
  X"2227",
  X"9277",
  X"e1de",
  X"8289",
  X"1223",
  X"9289",
  X"c1d6",
  X"1227",
  X"2228",
  X"9277",
  X"e1e7",
  X"828a",
  X"1223",
  X"928a",
  X"8277",
  X"c1df",
  X"1228",
  X"2229",
  X"9277",
  X"e1f0",
  X"828b",
  X"1223",
  X"928b",
  X"8277",
  X"c1e8",
  X"1229",
  X"222a",
  X"9277",
  X"e1f9",
  X"828c",
  X"1223",
  X"928c",
  X"8277",
  X"c1f1",
  X"122a",
  X"928d",
  X"8289",
  X"d207",
  X"f212",
  X"828a",
  X"f212",
  X"828b",
  X"f212",
  X"828c",
  X"f212",
  X"828d",
  X"f212",
  X"a100",
  X"828a",
  X"d20a",
  X"c1ff",
  X"828b",
  X"d20d",
  X"c201",
  X"828c",
  X"d210",
  X"c203",
  X"828d",
  X"c205",
  X"1242",
  X"9283",
  X"f18f",
  X"a100",
  X"5000",
  X"9277",
  X"8230",
  X"9283",
  X"f18f",
  X"8277",
  X"c1d6",
  X"b030",
  X"8fff",
  X"9273",
  X"a020",
  X"a200",
  X"0000",
  X"0001",
  X"0002",
  X"000a",
  X"ff00",
  X"2710",
  X"03e8",
  X"0064",
  X"000a",
  X"07ff",
  X"0102",
  X"0008",
  X"00ff",
  X"002b",
  X"002d",
  X"002a",
  X"0028",
  X"0029",
  X"0030",
  X"0031",
  X"0032",
  X"0033",
  X"0034",
  X"0035",
  X"0036",
  X"0037",
  X"0038",
  X"0039",
  X"002f",
  X"003d",
  X"2d2d",
  X"2020",
  X"0030",
  X"ff20",
  X"ff00",
  X"00ff",
  X"4572",
  X"726f",
  X"7221",
  X"0000",
  X"0246",
  X"5265",
  X"7375",
  X"6c74",
  X"3a20",
  X"0000",
  X"024b",
  X"5765",
  X"6c63",
  X"6f6d",
  X"6520",
  X"746f",
  X"2074",
  X"6865",
  X"2075",
  X"6c74",
  X"696d",
  X"6174",
  X"6520",
  X"4c4d",
  X"4520",
  X"6361",
  X"6c63",
  X"756c",
  X"6174",
  X"6f72",
  X"2120",
  X"0000",
  X"0251",
  X"5265",
  X"616c",
  X"6c79",
  X"3f3f",
  X"3f20",
  X"0000",
  X"0267",
  X"0800",
  X"0640",
  X"0028",
  X"0e3f",
  X"004f",
  X"0000",
  X"0000",
  X"0000",
  X"0000",
  X"0000",
  X"0000",
  X"0000",
  X"0000",
  X"0000",
  X"0000",
  X"0000",
  X"0000",
  X"0000",
  X"0000",
  X"0000",
  X"0000",
  X"0000",
  X"0000",
  X"0000",
  X"0000",
  X"0001",
  X"0000",
  X"0000",
  X"0000",
  X"0000",
  X"0000",
  X"0000",
  X"028f",
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







