----------------------------------------------------------------------------------
-- Engineer:       Nicholas Feix
--
-- Create Date:    15:30:06 06/17/2017
-- Design Name:
-- Module Name:    vga_controller - Behavioral
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use work.all;


entity vga_controller is
   port ( clk        : in  std_logic;
          reset      : in  std_logic;
          addressbus : in  std_logic_vector(10 downto 0);
          databus    : in  std_logic_vector(15 downto 0);
          we         : in  std_logic;
          hsync      : out std_logic;
          vsync      : out std_logic;
          red        : out std_logic;
          green      : out std_logic;
          blue       : out std_logic );
end vga_controller;

architecture Simulation of vga_controller is
   signal mem_data : std_logic_vector(15 downto 0);
   signal addr_int : std_logic_vector(10 downto 0);
   signal read_en : std_logic;

begin

   ctrl_unit: entity vga_routing
   port map (
      clk         => clk,
      reset       => reset,
      hsync       => hsync,
      vsync       => vsync,
      red         => red,
      green       => green,
      blue        => blue,
      mem_data    => mem_data,
      addr_int    => addr_int,
      read_en     => read_en
   );

   mem_unit: entity vga_memory(Simulation)
   port map (
      clk         => clk,
      addr_wr     => addressbus,
      addr_rd     => addr_int,
      data_out    => mem_data,
      data_in     => databus,
      we          => we,
      oe          => read_en
   );

end Simulation;



architecture Synthesis of vga_controller is
   signal mem_data : std_logic_vector(15 downto 0);
   signal addr_int : std_logic_vector(10 downto 0);
   signal read_en : std_logic;

begin

   ctrl_unit: entity vga_routing
   port map (
      clk         => clk,
      reset       => reset,
      hsync       => hsync,
      vsync       => vsync,
      red         => red,
      green       => green,
      blue        => blue,
      mem_data    => mem_data,
      addr_int    => addr_int,
      read_en     => read_en
   );

   mem_unit: entity vga_memory(Synthesis)
   port map (
      clk         => clk,
      addr_wr     => addressbus,
      addr_rd     => addr_int,
      data_out    => mem_data,
      data_in     => databus,
      we          => we,
      oe          => read_en
   );

end Synthesis;

