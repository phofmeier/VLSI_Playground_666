----------------------------------------------------------------------------------
-- Engineer:       Nicholas Feix
--
-- Create Date:    15:30:06 06/26/2017
-- Design Name:
-- Module Name:    address_gen - Behavioral
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

entity vga_address_gen is
   port ( address       : out std_logic_vector(10 downto 0);
          read_en       : out std_logic;  -- '1' => address has changed
          byte_select   : out std_logic;  -- '1' => for high byte
          row_select    : out std_logic_vector(3 downto 0);
          bit_mask      : out std_logic_vector(7 downto 0);
          clk           : in std_logic;
          pixel_clk     : in std_logic;
          pixel_en      : in std_logic;
          pixel_top     : in std_logic;
          pixel_left    : in std_logic );
end vga_address_gen;

architecture Behavioral of vga_address_gen is
   signal x, y, x_n, y_n : unsigned(7 downto 0) := x"00";
   signal row : unsigned(3 downto 0) := x"0";
   signal x_slv, y_slv : std_logic_vector(7 downto 0);
   signal addr, addr_n, addr_line : std_logic_vector(10 downto 0) := (others => '0');

begin

   position_reg: process(clk, pixel_clk, pixel_en, pixel_top, pixel_left, x, y)
   begin
      if ( pixel_en = '1' ) then
         x_n <= x + 1;
      else
         x_n <= x;
      end if;
      if pixel_left = '1' then
         y_n <= y + 1;
      else
         y_n <= y;
      end if;

      if rising_edge(clk) then
         if pixel_clk = '0' then
            if pixel_left = '1' then
               x <= x"00";
            else
               x <= x_n;
            end if;
            if pixel_top = '1' then
               y <= x"00";
            else
               y <= y_n;
            end if;
         end if;
      end if;
   end process position_reg;

   int_to_slv: process(x, y, row)
   begin
      x_slv <= std_logic_vector(x);
      y_slv <= std_logic_vector(y);
      row_select <= std_logic_vector(row);
   end process;

   address_reg: process(clk, pixel_clk, pixel_en, pixel_top, pixel_left, x_slv, addr, row, addr_line)
   begin
      addr_n <= addr;
      read_en <= '0';

      if ( pixel_en = '1' ) then
         if ( x_slv(3 downto 0) = "1111" ) then
            addr_n <= std_logic_vector(unsigned(addr) + 1);
            read_en <= '1';
         end if;
      elsif pixel_left = '1' then
         if row /= x"B" then
            addr_n <= addr_line;
            read_en <= '1';
         end if;
      else
      end if;

      if rising_edge(clk) then
         if pixel_clk = '0' then
            if pixel_top = '1' then
               row <= x"0";
               addr <= (others => '0');
               addr_line <= (others => '0');
            elsif pixel_left = '1' then
               if row = x"B" then
                  row <= x"0";
                  addr_line <= addr_n;
               else
                  row <= row + 1;
                  addr <= addr_line;
               end if;
            else
               addr <= addr_n;
            end if;
         end if;
      end if;

      -- case x_slv(2 downto 0) is
      --    when "000" =>   bit_mask <= X"80";
      --    when "001" =>   bit_mask <= X"40";
      --    when "010" =>   bit_mask <= X"20";
      --    when "011" =>   bit_mask <= X"10";
      --    when "100" =>   bit_mask <= X"08";
      --    when "101" =>   bit_mask <= X"04";
      --    when "110" =>   bit_mask <= X"02";
      --    when others => bit_mask <= X"01";
      -- end case;
      case x_slv(2 downto 0) is
         when "000" =>   bit_mask <= X"01";
         when "001" =>   bit_mask <= X"02";
         when "010" =>   bit_mask <= X"04";
         when "011" =>   bit_mask <= X"08";
         when "100" =>   bit_mask <= X"10";
         when "101" =>   bit_mask <= X"20";
         when "110" =>   bit_mask <= X"40";
         when others => bit_mask <= X"80";
      end case;
   end process address_reg;

   byte_select <= not x_slv(3);
   address <= addr_n;

end Behavioral;

