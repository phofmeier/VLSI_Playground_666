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
          instruction         : in std_logic_vector(15 downto 0);
          zero_flag           : in std_logic;
          neg_flag            : in std_logic;
          ien                 : in std_logic_vector(8 downto 0);
          iflags              : in std_logic_vector(7 downto 0);
          ireset              : out std_logic_vector(7 downto 0);
          ivector             : out std_logic_vector(2 downto 0);
          enPC, enIR, enACC   : out std_logic;
          enPSW, enSP, enPTR1 : out std_logic;
          enPTR2, enPTR3      : out std_logic;
          enIEN, enIFLAG      : out std_logic;
          --enRes               : out std_logic;
          selA, selData       : out std_logic_vector(1 downto 0);
          selB, selAddr       : out std_logic_vector(2 downto 0);
          selPSW              : out std_logic;
          selIEN, selIFLAG    : out std_logic;
          oe, we, gie         : out std_logic;
          ALUfunc             : out std_logic_vector(3 downto 0);
          nBit, shiftrot      : out std_logic );
end UKM910_ctrl;

architecture Behavioral of UKM910_ctrl is

   type STATES is (
      RESET, FETCH1, FETCH2, DECODE, EXECUTE_INT1, EXECUTE_INT2,
      EXECUTE_MAIN, EXECUTE_LOAD, --EXECUTE_STOREI,
      EXECUTE_IINC, EXECUTE_IDEC, EXECUTE_STORER, EXECUTE_STORE,
      EXECUTE_RETURN, EXECUTE_CALL1, EXECUTE_CALL2 );

   signal state, next_state : STATES := RESET;
   signal icurrent : std_logic_vector(7 downto 0) := (others => '0');
   signal regICURR : std_logic_vector(7 downto 0);
   signal enICURR : std_logic;

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
   -- Instruction subgroup 1
   constant OPG_LOADR      : std_logic_vector(11 downto 0) := "101000000000";
   constant OPG_LOADI      : std_logic_vector(11 downto 0) := "101000000001";
   constant OPG_LOADIINC   : std_logic_vector(11 downto 0) := "101000000010";
   constant OPG_LOADIDEC   : std_logic_vector(11 downto 0) := "101000000011";
   constant OPG_RET        : std_logic_vector(11 downto 0) := "101000010000";
   constant OPG_RETI       : std_logic_vector(11 downto 0) := "101000100000";
   -- Instruction subgroup 2
   constant OPG_STORER     : std_logic_vector(11 downto 0) := "101100000000";
   constant OPG_STOREI     : std_logic_vector(11 downto 0) := "101100000001";
   constant OPG_STOREIINC  : std_logic_vector(11 downto 0) := "101100000010";
   constant OPG_STOREIDEC  : std_logic_vector(11 downto 0) := "101100000011";

   constant SEL_DATA_HIGHZ : std_logic_vector(1 downto 0) := "00";
   constant SEL_DATA_PC    : std_logic_vector(1 downto 0) := "01";
   constant SEL_DATA_ACC   : std_logic_vector(1 downto 0) := "10";

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
   -- constant SEL_ADDR_RESULT: std_logic_vector(2 downto 0) := "011";
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

state_register: process(clk, res) begin
   if res = '1' then
      state <= RESET;  -- execute hard reset immediately
   elsif rising_edge(clk) then
      state <= next_state;
   end if;
end process;

control_logic: process(state, instruction, zero_flag, neg_flag, ien, iflags, regICURR)
begin
   -- Default control outputs (typical value)
   ireset   <= "00000000";
   icurrent <= "00000000";
   ivector  <= "000";
   enICURR  <= '0';
   enACC    <= '0';
   enPC     <= '0';
   enIR     <= '0';
   enSP     <= '0';
   enPTR1   <= '0';
   enPTR2   <= '0';
   enPTR3   <= '0';
   enPSW    <= '0';
   enIEN    <= '0';
   enIFLAG  <= '1';
   --enRes    <= '0';
   selData  <= SEL_DATA_HIGHZ;
   selA     <= SEL_A_ACC;
   selB     <= (others => '-');
   selAddr  <= (others => '-');
   selPSW   <= SEL_PSW_CTRL;
   selIEN   <= SEL_IEN_CTRL;
   selIFLAG <= SEL_IFLAG_EXT;
   we       <= '0';
   oe       <= '0';
   gie      <= '0';
   ALUfunc  <= (others => '-');
   nBit     <= '0';
   shiftrot <= instruction(3);  -- just to avoid 'unused signal' warning

   case ( state ) is
      -- ################################
      when RESET =>
         ireset      <= "11111111";  -- reset all interrupt flags
         enPC        <= '1';
         enIEN       <= '1';  -- clear IEN
         selIEN      <= SEL_IEN_RES;  -- clear interrupt enable register
         selIFLAG    <= SEL_IFLAG_RES;  -- reset interrupt flag register
         ALUfunc     <= ALU_ZERO;
         next_state  <= FETCH1;  -- continue execution of instruction at 0x000

      when FETCH1 =>
         if ( ien(8) = '1' and (ien(7 downto 0) and iflags) /= x"00" ) then
            enSP        <= '1';
            enIEN       <= '1';  -- set GIE to '0'
            selB        <= SEL_B_SP;
            ALUfunc     <= ALU_DEC_B;
            -- perform 2 intermediate steps to push the PC and load the int vector
            next_state  <= EXECUTE_INT1;
         else
            oe          <= '1';
            selAddr     <= SEL_ADDR_PC;
            selB        <= SEL_B_DATA;
            ALUfunc     <= ALU_EQ_B;
            next_state  <= FETCH2;
         end if;
      when FETCH2 =>
         enIR        <= '1';
         ALUfunc     <= ALU_EQ_B;
         selB        <= SEL_B_DATA;
         next_state  <= DECODE;

      when DECODE =>
         enPC     <= '1';
         ALUfunc  <= ALU_INC_B;
         selB     <= SEL_B_PC;
         case ( instruction(15 downto 12) ) is
            when OP_ADD | OP_SUB | OP_AND =>
               oe          <= '1';  -- apply address to memory during decode
               selAddr     <= SEL_ADDR_IR;
               next_state  <= EXECUTE_MAIN;
            when OP_NOT | OP_COMP | OP_ROTR | OP_SHR =>
               next_state  <= EXECUTE_MAIN;
            when OP_LOAD =>
               oe          <= '1';  -- apply address to memory during decode
               selAddr     <= SEL_ADDR_IR;
               next_state  <= EXECUTE_LOAD;
            when OP_STORE =>
               next_state  <= EXECUTE_STORE;
            when OP_GROUP1 =>
               case ( instruction(15 downto 4) ) is
                  when OPG_LOADR =>
                     next_state  <= EXECUTE_LOAD;
                  when OPG_LOADI | OPG_LOADIINC =>
                     oe          <= '1';  -- apply address to memory during decode
                     selAddr     <= '1' & instruction(1 downto 0);
                     next_state  <= EXECUTE_LOAD;
                  when OPG_LOADIDEC =>
                     --next_state  <= EXECUTE_IINC;
                     enPC        <= '0';
                     ALUfunc     <= ALU_DEC_B;
                     selB        <= '1' & instruction(1 downto 0);
                     case ( instruction(1 downto 0) ) is
                           when "00" =>   enSP   <= '1';
                           when "01" =>   enPTR1 <= '1';
                           when "10" =>   enPTR2 <= '1';
                           when others => enPTR3 <= '1';  -- "11"
                     end case;
                     next_state  <= EXECUTE_IDEC;
                  when OPG_RET | OPG_RETI =>
                     enPC        <= '0';
                     enSP        <= '1';
                     oe          <= '1';  -- apply address to memory during decode
                     selAddr     <= SEL_ADDR_SP;  -- use SP pre increment
                     selB        <= SEL_B_SP;  -- increment SP
                     next_state  <= EXECUTE_RETURN;
                  when others =>
                     next_state  <= FETCH1;
               end case;
            when OP_GROUP2 =>
               case ( instruction(15 downto 4) ) is
                  when OPG_STORER =>
                     next_state  <= EXECUTE_STORER;
                  when OPG_STOREI | OPG_STOREIINC =>
                     next_state  <= EXECUTE_STORE;
                  when OPG_STOREIDEC =>
                     --next_state  <= EXECUTE_IINC;
                     enPC        <= '0';
                     ALUfunc     <= ALU_DEC_B;
                     selB        <= '1' & instruction(1 downto 0);
                     case ( instruction(1 downto 0) ) is
                           when "00" =>   enSP   <= '1';
                           when "01" =>   enPTR1 <= '1';
                           when "10" =>   enPTR2 <= '1';
                           when others => enPTR3 <= '1';  -- "11"
                     end case;
                     next_state  <= EXECUTE_IDEC;
                  when others =>
                     next_state  <= FETCH1;
               end case;
            when OP_JUMP =>
               ALUfunc     <= ALU_EQ_B;
               selB        <= SEL_B_IR;
               next_state  <= FETCH1;
            when OP_BZ | OP_BN =>
               if ( (instruction(15 downto 12) = OP_BZ and zero_flag = '1') or
                    (instruction(15 downto 12) = OP_BN and neg_flag = '1') ) then
                  ALUfunc  <= ALU_EQ_B;
                  selB     <= SEL_B_IR;
               end if;
               next_state  <= FETCH1;
            when OP_CALL =>
               next_state  <= EXECUTE_CALL1;
            when others =>
               next_state  <= FETCH1;
         end case;

      when EXECUTE_MAIN =>
         enPSW    <= '1';
         enACC    <= '1';
         next_state <= FETCH1;
         case ( instruction(15 downto 12) ) is
            when OP_ADD | OP_SUB | OP_AND =>
               ALUfunc  <= instruction(15 downto 12);  -- direct relation
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

      when EXECUTE_LOAD =>
         enPSW       <= '1';
         enACC       <= '1';
         ALUfunc     <= ALU_EQ_B;
         selB        <= SEL_B_DATA;
         next_state  <= FETCH1;
         if instruction(15 downto 4) = OPG_LOADIINC then
            next_state  <= EXECUTE_IINC;
         elsif instruction(15 downto 4) = OPG_LOADR then
            if instruction(2) = '1' then
               -- select PSW, IEN or IFLAG
               ALUfunc  <= ALU_EQ_A;
               selA     <= instruction(1 downto 0);
            else
               -- select SP, PTR1, PTR2 or PTR3
               selB     <= '1' & instruction(1 downto 0);
            end if;
         end if;

      when EXECUTE_IDEC =>
         -- Increment the program counter and apply pointer to addressbus
         enPC        <= '1';
         selAddr     <= '1' & instruction(1 downto 0);
         ALUfunc     <= ALU_INC_B;
         selB        <= SEL_B_PC;
         if ( instruction(15 downto 4) = OPG_LOADIDEC ) then
            oe          <= '1';
            next_state  <= EXECUTE_LOAD;
         else  -- OPG_STOREIDEC
            next_state  <= EXECUTE_STORE;
         end if;

      when EXECUTE_STORE =>
         we          <= '1';
         --enRes       <= '1';
         selData     <= SEL_DATA_ACC;
         ALUfunc     <= ALU_EQ_A;
         if instruction(15 downto 12) = OP_STORE then
            selAddr     <= SEL_ADDR_IR;
         else
            selAddr     <= '1' & instruction(1 downto 0);
         end if;
         if instruction(15 downto 4) = OPG_STOREIINC then
            next_state  <= EXECUTE_IINC;
         else
            next_state  <= FETCH1;
         end if;

      when EXECUTE_IINC =>
         case ( instruction(1 downto 0) ) is
            when "00" =>   enSP   <= '1';
            when "01" =>   enPTR1 <= '1';
            when "10" =>   enPTR2 <= '1';
            when others => enPTR3 <= '1';  -- "11"
         end case;
         selB     <= '1' & instruction(1 downto 0);
         case ( instruction(15 downto 4) ) is
            -- when OPG_LOADIDEC =>
            --    oe          <= '1';
            --    selAddr     <= SEL_ADDR_RESULT;
            --    ALUfunc     <= ALU_DEC_B;
            --    next_state  <= EXECUTE_LOAD;
            when OPG_STOREIDEC =>
               ALUfunc     <= ALU_DEC_B;
               next_state  <= EXECUTE_STORE;
            when others =>
               ALUfunc     <= ALU_INC_B;
               next_state  <= FETCH1;
         end case;

      when EXECUTE_STORER =>
         ALUfunc     <= ALU_EQ_A;
         case ( instruction(2 downto 0) ) is
            when "000" =>  enSP   <= '1';
            when "001" =>  enPTR1 <= '1';
            when "010" =>  enPTR2 <= '1';
            when "011" =>  enPTR3 <= '1';
            when "100" =>
               enPSW    <= '1';
               selPSW   <= SEL_PSW_RES;
            when "101" =>
               enIEN    <= '1';
               selIEN   <= SEL_IEN_RES;
            when "110" =>
               enIFLAG  <= '1';
               selIFLAG <= SEL_IFLAG_RES;
            when others =>
               null;
         end case;
         next_state  <= FETCH1;

      when EXECUTE_RETURN =>
         enPC        <= '1';
         ALUfunc     <= ALU_EQ_B;
         selB        <= SEL_B_DATA;
         next_state  <= FETCH1;  -- continue
         if instruction(15 downto 4) = OPG_RETI then
            selIEN      <= SEL_IEN_CTRL;
            gie         <= '1';  -- global interrup enable
            enIEN       <= '1';
            ireset      <= regICURR;
         end if;

      when EXECUTE_CALL1 =>
         enSP        <= '1';
         ALUfunc     <= ALU_DEC_B;
         selB        <= SEL_B_SP;
         next_state  <= EXECUTE_CALL2;
      when EXECUTE_CALL2 =>
         we          <= '1';
         --enRes       <= '1';
         selData     <= SEL_DATA_PC;
         selAddr     <= SEL_ADDR_SP;
         enPC        <= '1';
         selB        <= SEL_B_IR;
         ALUfunc     <= ALU_EQ_B;
         next_state  <= FETCH1;

      when EXECUTE_INT1 =>
         -- decrement SP address interrupt vector
         we          <= '1';
         --enRes       <= '1';
         selData     <= SEL_DATA_PC;
         selAddr     <= SEL_ADDR_SP;
         --selB        <= SEL_B_PC;
         --ALUfunc     <= ALU_EQ_B;
         next_state  <= EXECUTE_INT2;
      when EXECUTE_INT2 =>
         -- address interrupt vector and reset the interrupt flag
         if ( (ien(0) and iflags(0)) = '1' ) then
            icurrent <= "00000001";
            ivector  <= "000";
         elsif ( (ien(1) and iflags(1)) = '1' ) then
            icurrent <= "00000010";
            ivector  <= "001";
         elsif ( (ien(2) and iflags(2)) = '1' ) then
            icurrent <= "00000100";
            ivector  <= "010";
         elsif ( (ien(3) and iflags(3)) = '1' ) then
            icurrent <= "00001000";
            ivector  <= "011";
         elsif ( (ien(4) and iflags(4)) = '1' ) then
            icurrent <= "00010000";
            ivector  <= "100";
         elsif ( (ien(5) and iflags(5)) = '1' ) then
            icurrent <= "00100000";
            ivector  <= "101";
         elsif ( (ien(6) and iflags(6)) = '1' ) then
            icurrent <= "01000000";
            ivector  <= "110";
         elsif ( (ien(7) and iflags(7)) = '1' ) then
            icurrent <= "10000000";
            ivector  <= "111";
         end if;
         enICURR     <= '1';
         enIFLAG     <= '1';
         oe          <= '1';
         selAddr     <= SEL_ADDR_IVECT;
         selB        <= SEL_B_DATA;
         ALUfunc     <= ALU_EQ_B;
         next_state  <= FETCH2;  -- continue with execution of interrupt vector

      when others =>
         next_state  <= RESET;
   end case;
end process;

ireset_register: process(clk) begin
   if rising_edge(clk) then
      if enICURR = '1' then
         regICURR <= icurrent;
      end if;
   end if;
end process;

end Behavioral;

