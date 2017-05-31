----------------------------------------------------------------------------------
-- Engineer:       Nicholas Feix
--
-- Create Date:    12:50:01 05/17/2017
-- Design Name:
-- Module Name:    UKM901_ctrl - Behavioral
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;


entity UKM901_ctrl is
   port ( clk, res            : in std_logic;
          opcode              : in std_logic_vector(3 downto 0);
          flags               : in std_logic_vector(2 downto 0);
          enPC, enIR, enACC   : out std_logic;
          enRes               : out std_logic;
          selAddr             : out std_logic;
          selB                : out std_logic_vector(1 downto 0);
          oe, wren            : out std_logic;
          ALUfunc             : out std_logic_vector(3 downto 0);
          nBit, shiftrot, dir : out std_logic);
end UKM901_ctrl;

architecture Behavioral of UKM901_ctrl is

   type STATES is (RESET, FETCH1, FETCH2, DECODE, EXECUTE, STORE);

   signal state, next_state : STATES;
   -- required due to timing issues
   signal enFLAGS : std_logic := '0';
   signal regFLAGS : std_logic_vector(2 downto 0);

   constant ALU_ZERO    : std_logic_vector(3 downto 0) := "0000";
   constant ALU_ADD     : std_logic_vector(3 downto 0) := "0001";
   constant ALU_SUB_AB  : std_logic_vector(3 downto 0) := "0010";
   constant ALU_SUB_BA  : std_logic_vector(3 downto 0) := "0011";
   constant ALU_EQ_A    : std_logic_vector(3 downto 0) := "0100";
   constant ALU_EQ_B    : std_logic_vector(3 downto 0) := "0101";
   constant ALU_INC_A   : std_logic_vector(3 downto 0) := "0110";
   constant ALU_INC_B   : std_logic_vector(3 downto 0) := "0111";
   constant ALU_AND     : std_logic_vector(3 downto 0) := "1000";
   constant ALU_OR      : std_logic_vector(3 downto 0) := "1001";
   constant ALU_XOR     : std_logic_vector(3 downto 0) := "1010";
   constant ALU_NOT_A   : std_logic_vector(3 downto 0) := "1100";
   constant ALU_NOT_B   : std_logic_vector(3 downto 0) := "1101";
   constant ALU_INV_A   : std_logic_vector(3 downto 0) := "1110";
   constant ALU_INV_B   : std_logic_vector(3 downto 0) := "1111";

   constant OP_NOP      : std_logic_vector(3 downto 0) := "0000";
   constant OP_ADD      : std_logic_vector(3 downto 0) := "0001";
   constant OP_SUB      : std_logic_vector(3 downto 0) := "0010";
   constant OP_AND      : std_logic_vector(3 downto 0) := "0011";
   constant OP_NOT      : std_logic_vector(3 downto 0) := "0100";
   constant OP_COMP     : std_logic_vector(3 downto 0) := "0101";
   constant OP_ROTR     : std_logic_vector(3 downto 0) := "0110";
   constant OP_SHR      : std_logic_vector(3 downto 0) := "0111";
   constant OP_LOAD     : std_logic_vector(3 downto 0) := "1000";
   constant OP_STORE    : std_logic_vector(3 downto 0) := "1001";
   constant OP_JUMP     : std_logic_vector(3 downto 0) := "1100";
   constant OP_BZ       : std_logic_vector(3 downto 0) := "1101";
   constant OP_BN       : std_logic_vector(3 downto 0) := "1110";

   constant SEL_B_PC    : std_logic_vector(1 downto 0) := "00";
   constant SEL_B_IR    : std_logic_vector(1 downto 0) := "01";
   constant SEL_B_DATA  : std_logic_vector(1 downto 0) := "10";

   constant SEL_ADDR_IR : std_logic := '0';
   constant SEL_ADDR_PC : std_logic := '1';

begin

flags_register: process(clk) begin
   if rising_edge(clk) then
      if enFLAGS = '1' then
         regFLAGS <= flags;
      end if;
   end if;
end process;

state_register: process(clk) begin
   if rising_edge(clk) then
      if res = '1' then
         state <= RESET;
      else
         state <= next_state;
      end if;
   end if;
end process;

control_logic: process(state, opcode, regFLAGS) begin
   case ( state ) is
      -- ################################
      when RESET =>
         enFLAGS  <= '0';
         enACC    <= 'X';
         enPC     <= '1';
         enIR     <= 'X';
         oe       <= '0';
         wren     <= '0';
         enRes    <= '0';
         nBit     <= '0';
         shiftrot <= 'X';
         dir      <= 'X';
         ALUfunc  <= ALU_ZERO;
         selAddr 	<= 'X';
         selB    	<= (others => 'X');
         next_state <= FETCH1;
      when FETCH1 =>
         enFLAGS  <= '0';
         enACC    <= '0';
         enPC     <= '0';
         enIR     <= '0';
         oe       <= '1';
         wren     <= '0';
         enRes    <= '0';
         nBit     <= '0';
         shiftrot <= 'X';
         dir      <= 'X';
         ALUfunc  <= ALU_EQ_B;
         selAddr  <= SEL_ADDR_PC;
         selB     <= SEL_B_DATA;
         next_state <= FETCH2;
      when FETCH2 =>
         enFLAGS  <= '0';
         enPC     <= '0';
         enIR     <= '1';
         enACC    <= '0';
         wren     <= '0';
         oe       <= '0';
         enRes    <= '0';
         nBit     <= '0';
         shiftrot <= 'X';
         dir      <= 'X';
         ALUfunc  <= ALU_EQ_B;
         selAddr  <= 'X';
         selB     <= SEL_B_DATA;
         next_state <= DECODE;
      when DECODE =>
         enFLAGS  <= '0';
         enACC    <= '0';
         enPC     <= '1';
         enIR     <= '0';
         wren     <= '0';
         enRes    <= '0';
         nBit     <= '0';
         shiftrot <= 'X';
         dir      <= 'X';
         case ( opcode ) is
            when OP_ADD | OP_SUB | OP_AND =>
               oe       <= '1';  -- apply address to memory during decode
               ALUfunc  <= ALU_INC_B;
               selAddr  <= SEL_ADDR_IR;
               selB     <= SEL_B_PC;
               next_state <= EXECUTE;
            when OP_NOT | OP_COMP | OP_ROTR | OP_SHR =>
               oe       <= '0';
               ALUfunc  <= ALU_INC_B;
               selAddr  <= 'X';
               selB     <= SEL_B_PC;
               next_state <= EXECUTE;
            when OP_LOAD =>
               oe       <= '1';  -- apply address to memory during decode
               ALUfunc  <= ALU_INC_B;
               selAddr  <= SEL_ADDR_IR;
               selB     <= SEL_B_PC;
               next_state <= EXECUTE;
            when OP_STORE =>
               oe       <= '0';
               ALUfunc  <= ALU_INC_B;
               selAddr  <= 'X';
               selB     <= SEL_B_PC;
               next_state <= STORE;
            when OP_JUMP =>
               oe       <= '0';
               ALUfunc  <= ALU_EQ_B;
               selAddr  <= 'X';
               selB     <= SEL_B_IR;
               next_state <= FETCH1;
            when OP_BZ | OP_BN =>
               oe       <= '0';
               selAddr  <= 'X';
               if ((opcode = OP_BZ and regFLAGS(1) = '1') or (opcode = OP_BN and regFLAGS(0) = '1')) then
                  ALUfunc <= ALU_EQ_B;
                  selB    <= SEL_B_IR;
               else
                  ALUfunc <= ALU_INC_B;
                  selB    <= SEL_B_PC;
               end if;
               next_state <= FETCH1;
            when others =>
               oe       <= '0';
               ALUfunc  <= ALU_INC_B;
               selB     <= SEL_B_PC;
               selAddr  <= 'X';
               next_state <= FETCH1;
         end case;
      when EXECUTE =>
         enFLAGS  <= '1';
         enACC    <= '1';
         enPC     <= '0';
         enIR     <= '0';
         wren     <= '0';
         oe       <= '0';
         enRes    <= '0';
         dir      <= '0';
         selAddr  <= 'X';
         next_state <= FETCH1;
         case ( opcode ) is
            when OP_ADD | OP_SUB | OP_AND =>
               if opcode = OP_AND then
                  ALUfunc <= ALU_AND;
               else
                  ALUfunc <= opcode;
               end if;
               nBit     <= '0';
               shiftrot <= 'X';
               selB     <= SEL_B_DATA;
            when OP_LOAD =>
               ALUfunc  <= ALU_EQ_B;
               nBit     <= '0';
               shiftrot <= 'X';
               selB     <= SEL_B_DATA;
            when OP_NOT =>
               ALUfunc  <= ALU_NOT_A;
               nBit     <= '0';
               shiftrot <= 'X';
               selB     <= (others => 'X');
            when OP_COMP =>
               ALUfunc  <= ALU_INV_A;
               nBit     <= '0';
               shiftrot <= 'X';
               selB     <= (others => 'X');
            when OP_ROTR =>
               ALUfunc  <= ALU_EQ_A;
               nBit     <= '1';
               shiftrot <= '1';
               selB     <= (others => 'X');
            when OP_SHR =>
               ALUfunc  <= ALU_EQ_A;
               nBit     <= '1';
               shiftrot <= '0';
               selB     <= (others => 'X');
            when others =>
               ALUfunc  <= (others => 'X');
               nBit     <= 'X';
               shiftrot <= 'X';
               selB     <= (others => 'X');
         end case;
      when STORE =>
         enFLAGS  <= '0';
         enACC    <= '0';
         enPC     <= '0';
         enIR     <= '0';
         wren     <= '1';
         oe       <= '0';
         enRes    <= '1';
         nBit     <= '0';
         shiftrot <= 'X';
         dir      <= '0';
         ALUfunc  <= ALU_EQ_A;
         selAddr  <= SEL_ADDR_IR;
         selB     <= (others => 'X');
         next_state <= FETCH1;
      when others =>
         enFLAGS  <= '0';
         enACC    <= 'X';
         enPC     <= 'X';
         enIR     <= 'X';
         wren     <= 'X';
         oe       <= 'X';
         enRes    <= 'X';
         nBit     <= 'X';
         shiftrot <= 'X';
         dir      <= 'X';
         ALUfunc  <= (others => 'X');
         selAddr  <= 'X';
         selB     <= (others => 'X');
         next_state <= RESET;
   end case;
end process;

end Behavioral;

