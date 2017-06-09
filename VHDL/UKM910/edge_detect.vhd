
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
   output <= notQ;

end process;

end Behavioral;
