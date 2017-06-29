----------------------------------------------------------------------------------
-- Engineer:       Nicholas Feix
--
-- Create Date:    12:50:01 05/17/2017
-- Design Name:
-- Module Name:    UKM910 - Behavioral
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

use work.all;

-- The 'reset' signal is asynchronous and will reset the state machine immediately
-- Interrupt 0 has the same effect as a 'reset' signal but can be controlled
-- through the IEN register. Furthermore it is buffered and synchronized with the
-- fetch phase of the state machine.
entity UKM910 is
   port ( clk, reset : in std_logic;
          interrupt  : in std_logic_vector (7 downto 0);
          oe, we     : out std_logic;
          addressbus : out std_logic_vector (11 downto 0);
          databus    : inout std_logic_vector (15 downto 0) );
end UKM910;

architecture Behavioral of UKM910 is

   signal data_in       : std_logic_vector(15 downto 0);
   signal result        : std_logic_vector(15 downto 0);
   signal A_bus, B_bus  : std_logic_vector(15 downto 0);
   signal ALUfunc       : std_logic_vector(3 downto 0);
   signal iinternal     : std_logic_vector(7 downto 0);
   signal ibuff         : std_logic_vector(7 downto 0);
   signal ireset        : std_logic_vector(7 downto 0);
   signal ivector       : std_logic_vector(2 downto 0);
   signal nBit          : std_logic;
   signal shiftrot      : std_logic;
   signal gie           : std_logic;
   signal ALUflags      : std_logic_vector(3 downto 0);
   -- MUX select lines
   signal selA          : std_logic_vector(1 downto 0);
   signal selB, selAddr : std_logic_vector(2 downto 0);
   signal selPSW        : std_logic;
   signal selIEN        : std_logic;
   signal selIFLAG      : std_logic;
   -- Register enable lines
   signal enPC, enIR, enACC, enRes     : std_logic;
   signal enPSW, enIEN, enIFLAG        : std_logic;
   signal enSP, enPTR1, enPTR2, enPTR3 : std_logic;
   -- Register definitions
   signal regPC         : std_logic_vector(11 downto 0) := (others => '0');
   signal regIR, regACC : std_logic_vector(15 downto 0) := (others => '0');
   signal regSP         : std_logic_vector(11 downto 0) := (others => '0');
   signal regPTR1       : std_logic_vector(11 downto 0) := (others => '0');
   signal regPTR2       : std_logic_vector(11 downto 0) := (others => '0');
   signal regPTR3       : std_logic_vector(11 downto 0) := (others => '0');
   signal regPSW        : std_logic_vector(3 downto 0)  := (others => '0');
   signal regIEN        : std_logic_vector(8 downto 0)  := (others => '0');
   signal regIFLAG      : std_logic_vector(7 downto 0)  := (others => '0');

   constant SEL_A_PSW      : std_logic_vector(1 downto 0) := "00";
   constant SEL_A_IEN      : std_logic_vector(1 downto 0) := "01";
   constant SEL_A_IFLAG    : std_logic_vector(1 downto 0) := "10";
   constant SEL_A_ACC      : std_logic_vector(1 downto 0) := "11";

   constant SEL_B_DATA     : std_logic_vector(2 downto 0) := "000";
   constant SEL_B_PC       : std_logic_vector(2 downto 0) := "001";
   constant SEL_B_IR       : std_logic_vector(2 downto 0) := "010";
   constant SEL_B_SP       : std_logic_vector(2 downto 0) := "100";
   constant SEL_B_PTR1     : std_logic_vector(2 downto 0) := "101";
   constant SEL_B_PTR2     : std_logic_vector(2 downto 0) := "110";
   constant SEL_B_PTR3     : std_logic_vector(2 downto 0) := "111";

   constant SEL_ADDR_IVECT : std_logic_vector(2 downto 0) := "000";
   constant SEL_ADDR_PC    : std_logic_vector(2 downto 0) := "001";
   constant SEL_ADDR_IR    : std_logic_vector(2 downto 0) := "010";
   constant SEL_ADDR_RESULT: std_logic_vector(2 downto 0) := "011";
   constant SEL_ADDR_SP    : std_logic_vector(2 downto 0) := "100";
   constant SEL_ADDR_PTR1  : std_logic_vector(2 downto 0) := "101";
   constant SEL_ADDR_PTR2  : std_logic_vector(2 downto 0) := "110";
   constant SEL_ADDR_PTR3  : std_logic_vector(2 downto 0) := "111";

   constant SEL_IEN_CTRL   : std_logic := '0';
   constant SEL_IEN_RES    : std_logic := '1';
   constant SEL_PSW_CTRL   : std_logic := '0';
   constant SEL_PSW_RES    : std_logic := '1';
   constant SEL_IFLAG_EXT  : std_logic := '0';
   constant SEL_IFLAG_RES  : std_logic := '1';

begin

   ctrl_unit: entity UKM910_ctrl
   port map(
      clk         => clk,
      res         => reset,
      ien         => regIEN,
      iflags      => regIFLAG,
      ireset      => ireset,
      ivector     => ivector,
      enPC        => enPC,
      enIR        => enIR,
      enACC       => enACC,
      enSP        => enSP,
      enPTR1      => enPTR1,
      enPTR2      => enPTR2,
      enPTR3      => enPTR3,
      enPSW       => enPSW,
      enIEN       => enIEN,
      enIFLAG     => enIFLAG,
      enRes       => enRes,
      selAddr     => selAddr,
      selA        => selA,
      selB        => selB,
      selPSW      => selPSW,
      selIEN      => selIEN,
      selIFLAG    => selIFLAG,
      oe          => oe,
      we          => we,
      gie         => gie,
      ALUfunc     => ALUfunc,
      nBit        => nBit,
      shiftrot    => shiftrot,
      instruction => regIR,
      zero_flag   => regPSW(0),
      neg_flag    => regPSW(1) );

   alu_unit: entity ALU
   port map(
      A        => A_bus,
      B        => B_bus,
      C        => result,
      ALUFunc  => ALUFunc,
      nBit     => nBit,
      shiftrot => shiftrot,
      z        => ALUflags(0),
      n        => ALUflags(1),
      cout     => ALUflags(2),
      ov       => ALUflags(3) );

   int_unit: entity edge_detect
   generic map (N => 8)
   port map(
      clk      => clk,
      input    => interrupt,
      reset    => ireset,
      output   => ibuff );

   addr_mux: process(selAddr, ivector, regPC, regIR, result, regSP, regPTR1, regPTR2, regPTR3) begin
      case ( selAddr ) is
         when SEL_ADDR_IVECT =>  -- only used for executing interrupt routines
            addressbus <= (11 downto 3 => '0') & ivector;
         when SEL_ADDR_PC =>
            addressbus <= regPC;
         when SEL_ADDR_IR =>
            addressbus <= regIR(11 downto 0);
         when SEL_ADDR_RESULT =>  -- only used for LOADIDEC (saves one cycle)
            addressbus <= result(11 downto 0);
         when SEL_ADDR_SP =>
            addressbus <= regSP;
         when SEL_ADDR_PTR1 =>
            addressbus <= regPTR1;
         when SEL_ADDR_PTR2 =>
            addressbus <= regPTR2;
         when others =>  -- SEL_ADDR_PTR3
            addressbus <= regPTR3;
      end case;
   end process;

   A_bus_mux: process(selA, regACC, regPSW, regIEN, regIFLAG) begin
      case ( selA ) is
         when SEL_A_PSW =>
            A_bus <= (15 downto 4 => '0') & regPSW;
         when SEL_A_IEN =>
            A_bus <= (15 downto 9 => '0') & regIEN;
         when SEL_A_IFLAG =>
            A_bus <= (15 downto 8 => '0') & regIFLAG;
         when others =>  -- SEL_A_ACC
            A_bus <= regACC;
      end case;
   end process;

   B_bus_mux: process(selB, data_in, regPC, regIR, regSP, regPTR1, regPTR2, regPTR3) begin
      case ( selB ) is
         when SEL_B_DATA =>
            B_bus <= data_in;
         when SEL_B_PC =>
            B_bus <= x"0" & regPC;
         when SEL_B_IR =>
            B_bus <= x"0" & regIR(11 downto 0);
         when SEL_B_SP =>
            B_bus <= x"0" & regSP;
         when SEL_B_PTR1 =>
            B_bus <= x"0" & regPTR1;
         when SEL_B_PTR2 =>
            B_bus <= x"0" & regPTR2;
         when SEL_B_PTR3 =>
            B_bus <= x"0" & regPTR3;
         when others =>
            B_bus <= (others => '-');
      end case;
   end process;

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
         if (enSP = '1') then
            regSP <= result(11 downto 0);
         end if;
         if (enPTR1 = '1') then
            regPTR1 <= result(11 downto 0);
         end if;
         if (enPTR2 = '1') then
            regPTR2 <= result(11 downto 0);
         end if;
         if (enPTR3 = '1') then
            regPTR3 <= result(11 downto 0);
         end if;
         if (enPSW = '1') then
            if selPSW = SEL_PSW_RES then
               regPSW <= result(3 downto 0);
            else
               regPSW <= ALUflags;
            end if;
         end if;
         if (enIEN = '1') then
            if selIEN = SEL_IEN_RES then
               regIEN <= result(8 downto 0);
            else
               regIEN(8) <= gie;
            end if;
         end if;
         if (enIFLAG = '1') then
            if selIFLAG = SEL_IFLAG_RES then
               regIFLAG <= result(7 downto 0);
            else
               regIFLAG <= iinternal and (not ireset);
            end if;
         end if;
      end if;
   end process;

   data_in <= databus when (enRes = '0') else (others => 'Z');
   databus <= result  when (enRes = '1') else (others => 'Z');
   iinternal <= ibuff or regIFLAG;

end Behavioral;

