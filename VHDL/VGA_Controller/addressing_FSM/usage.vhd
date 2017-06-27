

architecture Behavioral of UKM910_TB is

   ...

begin

   ...

   mem: entity memory(Simulation)
   port map(
      clk => clk,
      addr => addressbus(10 downto 0),
      dataIO => databus,
      we => we,
      oe => oe
   );

   ...

end;