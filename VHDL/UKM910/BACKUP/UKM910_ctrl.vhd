----------------------------------------------------------------------------------
-- Engineer:       Nicholas Feix
--
-- Create Date:    12:50:01 05/17/2017
-- Design Name:
-- Module Name:    UKM910_ctrl - Behavioral
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;


entity UKM910_ctrl is
   port ( clk, res            : in std_logic;
          opcode              : in std_logic_vector(11 downto 0);
          ALUflags            : in std_logic_vector(3 downto 0);
          ien                 : in std_logic_vector(8 downto 0);
          iflags              : in std_logic_vector(7 downto 0);
          ireset              : out std_logic_vector(7 downto 0);
          enPC, enIR, enACC   : out std_logic;
          enPSW, enSP, enPTR1 : out std_logic;
          enPTR2, enPTR3      : out std_logic;
          enIEN, enIFLAG      : out std_logic;
          enRes               : out std_logic;
          selA                : out std_logic_vector(1 downto 0);
          selB, selAddr       : out std_logic_vector(2 downto 0);
          selPSW              : out std_logic;
          selIEN, selIFLAG    : out std_logic;
          oe, wren, gie       : out std_logic;
          ALUfunc             : out std_logic_vector(3 downto 0);
          nBit, shiftrot      : out std_logic );
end UKM910_ctrl;

architecture Behavioral of UKM910_ctrl is

   type STATES is (RESET, FETCH1, FETCH2, DECODE, EXECUTE, STORE);

   signal state, next_state : STATES;

   constant ALU_ZERO       : std_logic_vector(3 downto 0) := "0000";
   constant ALU_ADD        : std_logic_vector(3 downto 0) := "0001";
   constant ALU_SUB        : std_logic_vector(3 downto 0) := "0010";
   constant ALU_AND        : std_logic_vector(3 downto 0) := "0011";
   constant ALU_EQ_A       : std_logic_vector(3 downto 0) := "0100";
   constant ALU_EQ_B       : std_logic_vector(3 downto 0) := "0101";
   constant ALU_DEC_B      : std_logic_vector(3 downto 0) := "0110";
   constant ALU_INC_B      : std_logic_vector(3 downto 0) := "0111";
   constant ALU_NOT_A      : std_logic_vector(3 downto 0) := "1000";
   constant ALU_NOT_B      : std_logic_vector(3 downto 0) := "1001";
   constant ALU_INV_A      : std_logic_vector(3 downto 0) := "1010";
   constant ALU_INV_B      : std_logic_vector(3 downto 0) := "1011";

   constant OP_NOP         : std_logic_vector(3 downto 0) := "0000";
   constant OP_ADD         : std_logic_vector(3 downto 0) := "0001";
   constant OP_SUB         : std_logic_vector(3 downto 0) := "0010";
   constant OP_AND         : std_logic_vector(3 downto 0) := "0011";
   constant OP_NOT         : std_logic_vector(3 downto 0) := "0100";
   constant OP_COMP        : std_logic_vector(3 downto 0) := "0101";
   constant OP_ROTR        : std_logic_vector(3 downto 0) := "0110";
   constant OP_SHR         : std_logic_vector(3 downto 0) := "0111";
   constant OP_LOAD        : std_logic_vector(3 downto 0) := "1000";
   constant OP_STORE       : std_logic_vector(3 downto 0) := "1001";
   constant OP_GROUP1      : std_logic_vector(3 downto 0) := "1010";
   constant OP_GROUP2      : std_logic_vector(3 downto 0) := "1011";
   constant OP_JUMP        : std_logic_vector(3 downto 0) := "1100";
   constant OP_BZ          : std_logic_vector(3 downto 0) := "1101";
   constant OP_BN          : std_logic_vector(3 downto 0) := "1110";
   constant OP_CALL        : std_logic_vector(3 downto 0) := "1111";
   -- Instruction subgroups
   constant OPG_LOADR      : std_logic_vector(11 downto 0) := "101000000000";
   constant OPG_LOADI      : std_logic_vector(11 downto 0) := "101000000001";
   constant OPG_LOADIINC   : std_logic_vector(11 downto 0) := "101000000010";
   constant OPG_LOADIDEC   : std_logic_vector(11 downto 0) := "101000000011";
   constant OPG_RET        : std_logic_vector(11 downto 0) := "101000010000";
   constant OPG_RETI       : std_logic_vector(11 downto 0) := "101000100000";
   constant OPG_STORER     : std_logic_vector(11 downto 0) := "101100000000";
   constant OPG_STOREI     : std_logic_vector(11 downto 0) := "101100000001";
   constant OPG_STOREIINC  : std_logic_vector(11 downto 0) := "101100000010";
   constant OPG_STOREIDEC  : std_logic_vector(11 downto 0) := "101100000011";

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

   constant SEL_ADDR_PC    : std_logic_vector(2 downto 0) := "001";
   constant SEL_ADDR_IR    : std_logic_vector(2 downto 0) := "010";
   constant SEL_ADDR_SP    : std_logic_vector(2 downto 0) := "100";
   constant SEL_ADDR_PTR1  : std_logic_vector(2 downto 0) := "101";
   constant SEL_ADDR_PTR2  : std_logic_vector(2 downto 0) := "110";
   constant SEL_ADDR_PTR3  : std_logic_vector(2 downto 0) := "111";

   constant SEL_PSW_CTRL   : std_logic := '0';
   constant SEL_PSW_RES    : std_logic := '1';
   constant SEL_IEN_CTRL   : std_logic := '0';
   constant SEL_IEN_RES    : std_logic := '1';
   constant SEL_IFLAG_EXT  : std_logic := '0';
   constant SEL_IFLAG_RES  : std_logic := '1';

begin

state_register: process(clk) begin
   if rising_edge(clk) then
      if res = '1' then
         state <= RESET;
      else
         state <= next_state;
      end if;
   end if;
end process;

control_logic: process(state, opcode, ALUflags, ien, iflags) begin
   -- Default control outputs (typical value)
   ireset   <= x"00";
   enACC    <= '0';
   enPC     <= '0';
   enIR     <= '0';
   enPSW    <= '0';
   enSP     <= '0';
   enPTR1   <= '0';
   enPTR2   <= '0';
   enPTR3   <= '0';
   enIEN    <= '0';
   enIFLAG  <= '0';
   enRes    <= '0';
   selA     <= SEL_A_ACC;
	selB    	<= (others => '-');
	selAddr 	<= (others => '-');
   selPSW   <= SEL_PSW_CTRL;
   selIEN   <= SEL_IEN_CTRL;
   selIFLAG <= SEL_IFLAG_EXT;
   wren     <= '0';
   oe       <= '0';
   gie      <= '0';
   nBit     <= '0';
   shiftrot <= '-';

   case ( state ) is
      -- ################################
      when RESET =>
         enPC     <= '1';
         ALUfunc  <= ALU_ZERO;
         next_state <= FETCH1;
      when FETCH1 =>
         oe       <= '1';
         ALUfunc  <= ALU_EQ_B;
         selAddr  <= SEL_ADDR_PC;
         selB     <= SEL_B_DATA;
         next_state <= FETCH2;
      when FETCH2 =>
         enIR     <= '1';
         nBit     <= '0';
         shiftrot <= '-';
         ALUfunc  <= ALU_EQ_B;
         selB     <= SEL_B_DATA;
         next_state <= DECODE;
      when DECODE =>
         enPC     <= '1';
         case ( opcode(11 downto 8) ) is
            when OP_ADD | OP_SUB | OP_AND =>
               oe          <= '1';  -- apply address to memory during decode
               ALUfunc     <= ALU_INC_B;
               selAddr     <= SEL_ADDR_IR;
               selB        <= SEL_B_PC;
               next_state  <= EXECUTE;
            when OP_NOT | OP_COMP | OP_ROTR | OP_SHR =>
               ALUfunc     <= ALU_INC_B;
               selB        <= SEL_B_PC;
               next_state  <= EXECUTE;
            when OP_LOAD =>
               oe          <= '1';  -- apply address to memory during decode
               ALUfunc     <= ALU_INC_B;
               selAddr     <= SEL_ADDR_IR;
               selB        <= SEL_B_PC;
               next_state  <= EXECUTE;
            when OP_STORE =>
               ALUfunc     <= ALU_INC_B;
               selB        <= SEL_B_PC;
               next_state  <= STORE;
            when OP_JUMP =>
               ALUfunc     <= ALU_EQ_B;
               selB        <= SEL_B_IR;
               next_state  <= FETCH1;
            when OP_BZ | OP_BN =>
               if ( (opcode(11 downto 8) = OP_BZ and ALUflags(1) = '1') or
                    (opcode(11 downto 8) = OP_BN and ALUflags(0) = '1') ) then
                  ALUfunc  <= ALU_EQ_B;
                  selB     <= SEL_B_IR;
               else
                  ALUfunc  <= ALU_INC_B;
                  selB     <= SEL_B_PC;
               end if;
               next_state  <= FETCH1;
            when others =>
               ALUfunc     <= ALU_INC_B;
               selB        <= SEL_B_PC;
               next_state  <= FETCH1;
         end case;
      when EXECUTE =>
         enPSW    <= '1';
         enACC    <= '1';
         next_state <= FETCH1;
         case ( opcode(11 downto 8) ) is
            when OP_ADD | OP_SUB | OP_AND =>
               ALUfunc  <= opcode(11 downto 8);  -- direct relation
               selB     <= SEL_B_DATA;
            when OP_LOAD =>
               ALUfunc  <= ALU_EQ_B;
               selB     <= SEL_B_DATA;
            when OP_NOT =>
               ALUfunc  <= ALU_NOT_A;
            when OP_COMP =>
               ALUfunc  <= ALU_INV_A;
            when OP_ROTR =>
               ALUfunc  <= ALU_EQ_A;
               nBit     <= '1';
               shiftrot <= '1';
            when OP_SHR =>
               ALUfunc  <= ALU_EQ_A;
               nBit     <= '1';
               shiftrot <= '0';
            when others =>
               ALUfunc  <= (others => '-');
               nBit     <= '-';
         end case;
      when STORE =>
         wren     <= '1';
         enRes    <= '1';
         ALUfunc  <= ALU_EQ_A;
         selAddr  <= SEL_ADDR_IR;
         next_state <= FETCH1;
      when others =>
         ALUfunc     <= (others => '-');
         next_state  <= RESET;
   end case;
end process;

end Behavioral;

