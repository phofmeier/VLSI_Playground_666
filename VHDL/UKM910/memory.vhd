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
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

use work.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity memory is
   port ( clk     : in std_logic;
          addr    : in std_logic_VECTOR (10 downto 0);
          dataIO  : inout std_logic_VECTOR (15 downto 0);
          we, oe  : in std_logic );
end memory;

architecture Simulation of memory is
   signal outp_int   : std_logic_vector(15 downto 0);
   signal oe_int     : std_logic;

begin

   mem: entity memory_int(Simulation)
   port map ( clk  => clk,
              addr => addr,
              inp  => dataIO,
              outp => outp_int,
              we   => we );

   oe_reg: process(clk)
   begin
      if rising_edge(clk) then
         oe_int <= oe;
      end if;
   end process oe_reg;

   outp_ctrl: process(oe_int, outp_int)
   begin
      if oe_int = '1' then
         dataIO <= outp_int;
      else
         dataIO <= (others => 'Z');
      end if;
   end process outp_ctrl;

end Simulation;


architecture Synthesis of memory is
   signal outp_int   : std_logic_vector(15 downto 0);
   signal oe_int     : std_logic;

begin

   mem: entity memory_int(Synthesis)
   port map ( clk  => clk,
              addr => addr,
              inp  => dataIO,
              outp => outp_int,
              we   => we );

   oe_reg: process(clk)
   begin
      if rising_edge(clk) then
         oe_int <= oe;
      end if;
   end process oe_reg;

   outp_ctrl: process(oe_int, outp_int)
   begin
      if oe_int = '1' then
         dataIO <= outp_int;
      else
         dataIO <= (others => 'Z');
      end if;
   end process outp_ctrl;

end Synthesis;

