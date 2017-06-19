----------------------------------------------------------------------------------
-- Engineer:       Nicholas Feix
--
-- Create Date:    12:50:01 05/17/2017
-- Design Name:
-- Module Name:    UKM901 - Behavioral
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

use work.all;


entity UKM901 is
   port ( oe	:	out std_logic;
          wren	:	out std_logic;
          res	:	in std_logic;
          clk	:	in std_logic;
          addressbus	:	out std_logic_vector (11 downto 0);
          databus	:	inout std_logic_vector (15 downto 0));
end UKM901;

architecture Behavioral of UKM901 is

   signal result  		: std_logic_vector(15 downto 0);
   signal A_bus, B_bus  : std_logic_vector(15 downto 0);
   signal ALUfunc			: std_logic_vector(3 downto 0);
   signal shiftrot_ctrl : std_logic_vector(2 downto 0);
   signal opcode 			: std_logic_vector(3 downto 0);
   signal flags         : std_logic_vector(2 downto 0);
   signal enPC, enIR, enACC, enRes : std_logic;
   signal selAddr       : std_logic;
   signal selB          : std_logic_vector(1 downto 0);
   -- Register definitions
   signal regPC  			: std_logic_vector(11 downto 0);
   signal regIR, regACC : std_logic_vector(15 downto 0);

   constant SEL_B_PC    : std_logic_vector(1 downto 0) := "00";
   constant SEL_B_IR    : std_logic_vector(1 downto 0) := "01";
   constant SEL_B_DATA  : std_logic_vector(1 downto 0) := "10";

   constant SEL_ADDR_IR : std_logic := '0';
   constant SEL_ADDR_PC : std_logic := '1';

begin

    ctrl_unit: entity UKM901_ctrl port map(
        clk	=> clk,
        res => res,
        enPC => enPC,
        enIR => enIR,
        enACC => enACC,
        enRes => enRes,
        selAddr => selAddr,
        selB => selB,
        oe => oe,
        wren => wren,
        ALUfunc => ALUfunc,
        nBit => shiftrot_ctrl(0),
        shiftrot => shiftrot_ctrl(1),
        dir => shiftrot_ctrl(2),
        opcode => opcode,
        flags => flags );

    alu_unit: entity ALU port map(
        A => A_bus,
        B => B_bus,
        C => result,
        ALUFunc => ALUFunc,
        nBit => shiftrot_ctrl(0),
        shiftrot => shiftrot_ctrl(1),
        dir => shiftrot_ctrl(2),
        n => flags(0),
        z => flags(1),
        cout => flags(2) );

   addr_mux: process(selAddr, regIR, regPC) begin
      if selAddr = SEL_ADDR_IR then
         addressbus <= regIR(11 downto 0);
      else  -- SEL_ADDR_PC
         addressbus <= regPC;
      end if;
   end process;

   B_bus_mux: process(selB, regIR, regPC, databus) begin
      if selB = SEL_B_IR then
         B_bus <= x"0" & regIR(11 downto 0);
      elsif selB = SEL_B_PC then
         B_bus <= x"0" & regPC;
      else  -- SEL_B_DATA
         B_bus <= databus;
      end if;
   end process;

   --databus_: process(enRes, result) begin
   --   if enRes = '1' then
   --      databus <= result;
   --   else  -- '2'
   --      databus <= (others <= 'Z');
   --   end if;
   --end process;

   registers: process(clk) begin
      if rising_edge(clk) then
         if (enPC = '1') then
            regPC <= result(11 downto 0);
         end if;
         if (enIR = '1') then
            regIR <= result;
         end if;
         if (enACC = '1') then
            regACC <= result;
         end if;
      end if;
   end process;

   A_bus <= regACC;
   databus <= result when (enRes = '1') else (others => 'Z');
   opcode <= regIR(15 downto 12);

end Behavioral;

