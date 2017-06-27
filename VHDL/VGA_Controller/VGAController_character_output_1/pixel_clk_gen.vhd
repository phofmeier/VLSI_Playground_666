----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:26:59 06/18/2017 
-- Design Name: 
-- Module Name:    pixel_clk_gen - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pixel_clk_gen is
    Port ( clk       : in  STD_LOGIC;
           reset     : in  STD_LOGIC;
           pixel_clk : out  STD_LOGIC);
end pixel_clk_gen;

architecture Behavioral of pixel_clk_gen is
--signal pixel_clk_signal : std_logic;

begin
--Clock_divide: process(clk,reset)
--begin
--   if (reset = '1') then
--      pixel_clk_signal <= '0';
--   elsif(rising_edge(clk))then
--      pixel_clk_signal <= not pixel_clk_signal;
--   end if;
--	pixel_clk <=pixel_clk_signal;
--end process Clock_divide;

--	reset_driver : 
--		reset <= '1', '0' after 30 ns ;

	clock_driver : process     
   variable tmp_clk : std_logic := '1';
   	begin	
    		tmp_clk := not tmp_clk;
    		pixel_clk	<= tmp_clk;
  		wait for 20 ns;
   end process clock_driver;


end Behavioral;

