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
      input, reset   : in  std_logic_vector(N-1 downto 0);
      output         : out std_logic_vector(N-1 downto 0) );
end edge_detect;

architecture Behavioral of edge_detect is
   -- constant ZERO  : std_logic_vector(N-1 downto 0) := (others => '0');
   signal Q    : std_logic_vector(N-1 downto 0);
   signal notQ : std_logic_vector(N-1 downto 0);

begin
process(input, reset, Q, notQ)
begin

   Q      <= input nor notQ;
   notQ   <= reset nor Q;

end process;


--GEN_edge_detect:
--   for i in 0 to N-1 generate
--		process(input(i), reset(i))
--		begin
--			if input(i) = '1' then
--				Q(i)    <= '1';
--				notQ(i) <= '0';
--			elsif reset(i) =  '1' then
--				Q(i)    <= '0';
--				notQ(i) <= '1';
--			end if;
--		end process;
--   end generate GEN_edge_detect;

 output <= notQ;

end Behavioral;
