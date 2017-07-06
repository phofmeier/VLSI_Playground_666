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

Library UNISIM;
use UNISIM.vcomponents.all;

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
   latch: for I in 0 to N-1 generate
      LDCE_inst: LDCE
      generic map (
         INIT => '1')      -- Initial value of latch
      port map (
         Q => Q(i),        -- Data output
         CLR => input(i),  -- Asynchronous clear/reset input
         D => '1',         -- Data input
         G => '1',         -- Gate input
         GE => reset(i)    -- Gate enable input
      );
   end generate;

   sync_ff: process(clk)
   begin
      -- synchronize the asynchronous input signal with an FF
      if rising_edge(clk) then
         buff_reg <= notQ;
      end if;
   end process sync_ff;

   notQ <= not Q;
   output <= (not reset) and buff_reg;

end Behavioral;
