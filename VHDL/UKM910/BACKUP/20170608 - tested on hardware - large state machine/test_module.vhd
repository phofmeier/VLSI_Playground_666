----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:20:33 06/07/2017 
-- Design Name: 
-- Module Name:    test_module - Behavioral
-----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity test_module is
    port ( clk, reset   : in  std_logic;
           we, oe     : in  std_logic;
           dataIO       : inout  std_logic_vector(15 downto 0));
end test_module;

architecture Behavioral of test_module is
   
   signal value : std_logic_vector(15 downto 0);
   
begin

handler: process(clk, reset)
begin
   if reset = '1' then
      dataIO   <= (others => 'Z');
      value    <= (others => '0');
   elsif rising_edge(clk) then
      -- reading from the module
      if oe = '1' then
         dataIO <= value;
      -- writing to the module
      elsif we = '1' then
         value <= dataIO;
      else
         dataIO <= (others => 'Z');
      end if;
   end if;
end process handler;

end Behavioral;

