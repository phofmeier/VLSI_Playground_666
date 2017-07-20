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
   signal read_en  : std_logic := '0';
   signal colors   : std_logic_vector(5 downto 0) := "011001";

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
      addr_rd     => addr_int,
      read_en     => read_en,
      colors      => colors
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
   type STATES is (
      IDLE, COPY_SPLASH_RD, COPY_SPLASH_WR );
   signal state, next_state : STATES := IDLE;

   signal data_in, data_out, data_spl : std_logic_vector(15 downto 0);
   signal addr_rd, addr_wr    : std_logic_vector(10 downto 0);
   signal addr_spl_next, addr_spl : unsigned(10 downto 0) := (others => '0');
   signal read_en  : std_logic := '0';
   signal write_en : std_logic := '0';
   signal read_spl : std_logic := '0';
   signal colors, colors_next : std_logic_vector(5 downto 0) := "011001";  -- "rgbrgb"

   constant ADDR_SET_COLOR  : std_logic_vector(10 downto 0) := "11111111110";
   constant ADDR_CP_SPLASH  : std_logic_vector(10 downto 0) := "11111111101";

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
      mem_data    => data_out,
      addr_rd     => addr_rd,
      read_en     => read_en,
      colors      => colors
   );

   mem_unit: entity vga_memory(Synthesis)
   port map (
      clk         => clk,
      addr_wr     => addr_wr,
      addr_rd     => addr_rd,
      data_out    => data_out,
      data_in     => data_in,
      we          => write_en,
      oe          => read_en
   );

   mem_splash: entity vga_memory(Synthesis)
   port map (
      clk         => clk,
      addr_wr     => (others => '0'),
      addr_rd     => addr_wr,
      data_out    => data_spl,
      data_in     => (others => '0'),
      we          => '0',
      oe          => read_spl
   );

   process(clk)
   begin
      if rising_edge(clk) then
         state <= next_state;
         colors <= colors_next;
         addr_spl <= addr_spl_next;
      end if;
   end process;
   
   addr_wr <= addressbus when state = IDLE else std_logic_vector(addr_spl);

   process(state, databus, addressbus, colors, we, addr_wr, data_spl)
   begin
      write_en    <= '0';
      read_spl    <= '0';
      data_in     <= databus;
      next_state  <= IDLE;
      colors_next <= colors;
      addr_spl_next <= (others => '0');
      case ( state ) is
         when IDLE =>
            if ( we = '1' ) then
               if ( addressbus = ADDR_SET_COLOR ) then
                  colors_next <= databus(5 downto 0);
               elsif ( addressbus = ADDR_CP_SPLASH ) then
                  next_state <= COPY_SPLASH_RD;
                  addr_spl_next <= (others => '0');
               else
                  write_en <= we;
               end if;
            end if;
         when COPY_SPLASH_RD =>
            read_spl <= '1';
            data_in  <= data_spl;
            addr_spl_next <= addr_spl;
            next_state <= COPY_SPLASH_WR;
         when COPY_SPLASH_WR =>
            write_en <= '1';
            data_in  <= data_spl;
            addr_spl_next <= addr_spl + 1;
            if ( addr_wr < x"640" ) then
               next_state <= COPY_SPLASH_RD;
            end if;
      end case;
   end process;

end Synthesis;

