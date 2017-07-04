----------------------------------------------------------------------------------
-- Engineer:       Nicholas Feix
--
-- Create Date:    13:30:00 06/14/2017
-- Design Name:
-- Module Name:    edge_detect - Behavioral
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

entity edge_detect is
   generic (N : positive := 8);
   port (
      clk            : in  std_logic;
      input, reset   : in  std_logic_vector(N-1 downto 0);
      output         : out std_logic_vector(N-1 downto 0) );
end edge_detect;

architecture Behavioral of edge_detect is
   signal Q, notQ  : std_logic_vector(N-1 downto 0);
   signal buff_reg : std_logic_vector(N-1 downto 0);

begin
   nor_latch: process(input, reset, Q, notQ)
   begin
      -- detect and hold asynchronous input signals with NOR latch
      Q      <= input nor notQ;
      notQ   <= reset nor Q;
   end process nor_latch;

   sync_ff: process(clk)
   begin
      -- synchronize the asynchronous input signal with an FF
      if rising_edge(clk) then
         buff_reg <= notQ;
      end if;
   end process sync_ff;

   --output <= notQ;
   output <= (not reset) and buff_reg;

end Behavioral;
