
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
      --input, reset   : in  std_logic_vector(7 downto 0);
      --output         : out std_logic_vector(7 downto 0) );
end edge_detect;

architecture Behavioral of edge_detect is
   signal state : std_logic_vector(N-1 downto 0) := (others => '0');
   --signal state : std_logic_vector(7 downto 0) := (others => '0');

begin

process(clk, input)
begin
   if or_reduce(input) = '1' then
      for i in 0 to N-1 loop
         if (input(i) = '1') then
            state(i) <= '1';
         end if;
      end loop;
   elsif rising_edge(clk) then
      for i in 0 to N-1 loop
         if (reset(i) = '1') then
            state(i) <= '0';
         end if;
      end loop;
   end if;
end process;

   output <= state;
end Behavioral;
