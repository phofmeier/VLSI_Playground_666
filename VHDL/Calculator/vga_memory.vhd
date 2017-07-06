----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    19:05:30 01/08/2008
-- Design Name:
-- Module Name:    memory - Behavioral
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


entity vga_memory is
   port ( clk        : in  std_logic;
          addr_rd    : in  std_logic_vector(10 downto 0);
          addr_wr    : in  std_logic_vector(10 downto 0);
          data_out   : out std_logic_vector(15 downto 0);
          data_in    : in  std_logic_vector(15 downto 0);
          we, oe     : in  std_logic );
end vga_memory;

architecture Simulation of vga_memory is
   type saveArray is array (0 to (40 * 40)) of std_logic_vector(15 downto 0);
   signal data : saveArray := (others => (others => '0'));
   signal addr_rd_int : integer range 0 to 1600;
   signal addr_wr_int : integer range 0 to 1600;
begin

   mem_ctrl: process(clk, addr_rd_int, addr_wr_int)
      variable init      : integer := 0;
      file inputfile     : text open read_mode is "../vga_memory.txt";
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
            data(addr_wr_int) <= data_in;
         end if;
         if oe = '1' then
            data_out <= data(addr_rd_int);
         end if;
      end if;
   end process mem_ctrl;
   
   addr_rd_int <= conv_integer(unsigned(addr_rd));
   addr_wr_int <= conv_integer(unsigned(addr_wr));
end Simulation;


architecture Synthesis of vga_memory is
   type saveArray is array (0 to (40 * 40)) of std_logic_vector(15 downto 0);
   signal addr_rd_int : integer range 0 to 1600;
   signal addr_wr_int : integer range 0 to 1600;
   signal data : saveArray := (
      x"2b20", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"202b",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2061", x"6161", x"6161", x"2020", x"2020", x"2061", x"6161", x"6120", x"6161", x"6161", x"2020", x"2020", x"6161", x"6161", x"2061", x"6161", x"6120", x"2020", x"2020",
      x"2020", x"2061", x"6161", x"6161", x"2020", x"2e61", x"6161", x"6161", x"2e20", x"2020", x"2020", x"2e61", x"2020", x"2020", x"2e61", x"6161", x"612e", x"2020", x"2020", x"2020",
      x"2020", x"2060", x"3838", x"3827", x"2020", x"2020", x"2060", x"3838", x"2720", x"6038", x"3838", x"2020", x"202e", x"3850", x"2720", x"2060", x"3838", x"382e", x"2020", x"2020",
      x"2020", x"6438", x"3838", x"3827", x"2038", x"3838", x"2720", x"6059", x"3838", x"2e20", x"6138", x"3838", x"2020", x"2064", x"3850", x"2760", x"5938", x"6220", x"2020", x"2020",
      x"2020", x"2020", x"3838", x"3820", x"2020", x"2020", x"2020", x"3838", x"2020", x"2038", x"3838", x"2020", x"6438", x"2720", x"2020", x"2020", x"3838", x"3838", x"6220", x"2020",
      x"2064", x"5027", x"7c38", x"3820", x"2038", x"3838", x"2020", x"2020", x"3838", x"3820", x"2038", x"3838", x"2020", x"3838", x"3820", x"2020", x"2038", x"3838", x"2020", x"2020",
      x"2020", x"2020", x"3838", x"3820", x"2020", x"2020", x"2020", x"3838", x"2020", x"2038", x"3838", x"3838", x"5b20", x"2020", x"2020", x"2020", x"3838", x"2059", x"3838", x"2e20",
      x"6450", x"2020", x"7c38", x"3820", x"2020", x"6056", x"6261", x"6164", x"3838", x"3820", x"2038", x"3838", x"2020", x"3838", x"3820", x"2020", x"2038", x"3838", x"2020", x"2020",
      x"2020", x"2020", x"3838", x"3820", x"2020", x"2020", x"2020", x"3838", x"2020", x"2038", x"3838", x"6038", x"3862", x"2e20", x"2020", x"2020", x"3838", x"2020", x"6038", x"3838",
      x"2720", x"2020", x"7c38", x"3820", x"2020", x"2020", x"2020", x"2038", x"3838", x"2720", x"2038", x"3838", x"2020", x"3838", x"3820", x"2020", x"2038", x"3838", x"2020", x"2020",
      x"2020", x"2020", x"6038", x"382e", x"2020", x"2020", x"2064", x"3827", x"2020", x"2038", x"3838", x"2020", x"6038", x"3862", x"2e20", x"2020", x"3838", x"2020", x"2020", x"5920",
      x"2020", x"2020", x"7c38", x"3820", x"2020", x"2020", x"202e", x"3838", x"5027", x"2020", x"2038", x"3838", x"2020", x"6038", x"3862", x"2020", x"6438", x"3827", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"6059", x"6261", x"6164", x"5027", x"2020", x"2020", x"6138", x"3838", x"6120", x"2061", x"3838", x"3861", x"2061", x"3838", x"6120", x"2020", x"2020",
      x"2020", x"2061", x"3838", x"3861", x"2020", x"202e", x"6150", x"2720", x"2020", x"2020", x"6138", x"3838", x"6120", x"2060", x"5938", x"6264", x"3850", x"2720", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"3d3d", x"3d3d", x"3d3d", x"3d3d", x"3d3d", x"3d3d", x"3d3d", x"3d3d", x"3d3d", x"3d3d", x"3d3d", x"3d3d", x"3d3d", x"3d3d", x"3d3d", x"3d3d",
      x"3d3d", x"3d3d", x"3d3d", x"3d3d", x"3d3d", x"3d3d", x"3d3d", x"3d3d", x"3d3d", x"3d3d", x"3d3d", x"3d3d", x"3d3d", x"3d3d", x"3d3d", x"3d3d", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2e64", x"3838", x"3838", x"3862", x"2e20", x"2020", x"2020", x"2020", x"2020", x"2064", x"3838", x"3838", x"2020",
      x"2020", x"3838", x"3820", x"2020", x"2020", x"2020", x"2020", x"2e64", x"3838", x"3838", x"3862", x"2e20", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2064", x"3838", x"5020", x"2020", x"5938", x"3862", x"2020", x"2020", x"2020", x"2020", x"6438", x"3838", x"3838", x"2020",
      x"2020", x"3838", x"3820", x"2020", x"2020", x"2020", x"2064", x"3838", x"5020", x"2020", x"5938", x"3862", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2038", x"3838", x"2020", x"2020", x"2038", x"3838", x"2020", x"2020", x"2020", x"2064", x"3838", x"5038", x"3838", x"2020",
      x"2020", x"3838", x"3820", x"2020", x"2020", x"2020", x"2038", x"3838", x"2020", x"2020", x"2038", x"3838", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2038", x"3838", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"6438", x"3850", x"2038", x"3838", x"2020",
      x"2020", x"3838", x"3820", x"2020", x"2020", x"2020", x"2038", x"3838", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2038", x"3838", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2064", x"3838", x"5020", x"2038", x"3838", x"2020",
      x"2020", x"3838", x"3820", x"2020", x"2020", x"2020", x"2038", x"3838", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2038", x"3838", x"2020", x"2020", x"2038", x"3838", x"2020", x"2020", x"6438", x"3850", x"2020", x"2038", x"3838", x"2020",
      x"2020", x"3838", x"3820", x"2020", x"2020", x"2020", x"2038", x"3838", x"2020", x"2020", x"2038", x"3838", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2059", x"3838", x"6220", x"2020", x"6438", x"3850", x"2020", x"2064", x"3838", x"3838", x"3838", x"3838", x"3838", x"2020",
      x"2020", x"3838", x"3861", x"6161", x"6161", x"2020", x"2059", x"3838", x"6220", x"2020", x"6438", x"3850", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2259", x"3838", x"3838", x"3850", x"2220", x"2020", x"6438", x"3850", x"2020", x"2020", x"2038", x"3838", x"2020",
      x"2020", x"3838", x"3838", x"3838", x"3838", x"2020", x"2020", x"2259", x"3838", x"3838", x"3850", x"2220", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2b20", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020",
      x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"2020", x"202b",
      others => X"0000" );

begin

   mem_ctrl: process(clk, addr_rd_int, addr_wr_int)
   begin
      if rising_edge(clk) then
         if we = '1' then
            data(addr_wr_int) <= data_in;
         end if;
         if oe = '1' then
            data_out <= data(addr_rd_int);
         end if;
      end if;
   end process mem_ctrl;
   
   addr_rd_int <= conv_integer(unsigned(addr_rd));
   addr_wr_int <= conv_integer(unsigned(addr_wr));

end Synthesis;

