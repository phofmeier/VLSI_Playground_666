
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

entity edge_detect is
   generic (N : positive := 8);
   port (
--      clk            : in  std_logic;
      input, reset   : in  std_logic_vector(N-1 downto 0);
      output         : out std_logic_vector(N-1 downto 0) );
end edge_detect;

architecture Behavioral of edge_detect is
   -- constant ZERO  : std_logic_vector(N-1 downto 0) := (others => '0');
   signal Q    : std_logic_vector(N-1 downto 0);
   signal notQ : std_logic_vector(N-1 downto 0);

begin

--process(clk, input)
--begin
--   -- if input /= ZERO then
--   --    temp <= input or temp;
--   if input(0) = '1' then
--      temp(0) <= '1';
--   elsif rising_edge(clk) then
--      if reset(0) = '1' then
--         temp(0) <= '0';
--      end if;
--      -- temp(0) <= (temp and (not reset)) or input;
--   end if;
--end process;

process(input, reset, Q, notQ)
begin

   Q      <= input nor notQ;
   notQ   <= reset nor Q;
   output <= notQ;
   
end process;

end Behavioral;
