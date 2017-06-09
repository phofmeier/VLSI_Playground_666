
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

entity ALU is
   port (
      A, B           : in  std_logic_vector(15 downto 0);
      C              : out std_logic_vector(15 downto 0);
      ALUFunc        : in  std_logic_vector(3 downto 0);
      nBit, shiftrot : in  std_logic;
      n, z, cout, ov : out std_logic );
end ALU;

architecture behaviour of ALU is
   signal calc : unsigned(16 downto 0);
   signal result : std_logic_vector(15 downto 0);

   constant ALU_ZERO    : std_logic_vector(3 downto 0) := "0000";
   constant ALU_ADD     : std_logic_vector(3 downto 0) := "0001";
   constant ALU_SUB     : std_logic_vector(3 downto 0) := "0010";
   constant ALU_AND     : std_logic_vector(3 downto 0) := "0011";
   constant ALU_EQ_A    : std_logic_vector(3 downto 0) := "0100";
   constant ALU_EQ_B    : std_logic_vector(3 downto 0) := "0101";
   constant ALU_DEC_B   : std_logic_vector(3 downto 0) := "0110";
   constant ALU_INC_B   : std_logic_vector(3 downto 0) := "0111";
   constant ALU_NOT_A   : std_logic_vector(3 downto 0) := "1000";
   constant ALU_NOT_B   : std_logic_vector(3 downto 0) := "1001";
   constant ALU_INV_A   : std_logic_vector(3 downto 0) := "1010";
   constant ALU_INV_B   : std_logic_vector(3 downto 0) := "1011";

begin

func: process(ALUFunc, nBit, shiftrot, A, B)
begin
   case ALUFunc is
      -- ################################
      when ALU_ZERO =>
         calc <= (others => '0');
      when ALU_ADD =>
         calc <= unsigned('0' & A) + unsigned('0' & B);
      when ALU_SUB =>
         calc <= unsigned('0' & A) - unsigned('1' & B);
      when ALU_AND =>
         calc <= unsigned('0' & (A and B));
      -- ################################
      when ALU_EQ_A =>
         calc <= unsigned('0' & A);
      when ALU_EQ_B =>
         calc <= unsigned('0' & B);
      when ALU_DEC_B =>
         calc <= unsigned('0' & B) - 1;
      when ALU_INC_B =>
         calc <= unsigned('0' & B) + 1;
      -- ################################
      when ALU_NOT_A =>
         calc <= not unsigned('1' & A);
      when ALU_NOT_B =>
         calc <= not unsigned('1' & B);
      when ALU_INV_A =>
         calc <= not unsigned('1' & A) + 1;
      when ALU_INV_B =>
         calc <= not unsigned('1' & B) + 1;
      -- ################################
      when others =>
         calc <= (others => '0');
   end case;
end process;

   result <= std_logic_vector(calc(15 downto 0)) when nBit = '0'
      else std_logic_vector(calc(15 downto 0) srl 1) when (shiftrot = '0')
      else std_logic_vector(calc(15 downto 0) ror 1) when (shiftrot = '1')
      else (others => '0');

   ov <= (not (A(15) xor B(15)) and (calc(15) xor A(15))) when ALUFunc = ALU_ADD
      else ((A(15) xor B(15)) and (calc(15) xor A(15))) when ALUFunc = ALU_SUB
      else (not (calc(15) xor A(15))) when ALUFunc = ALU_INV_A
      else (not (calc(15) xor B(15))) when ALUFunc = ALU_INV_B
      else '0';

   z <= not or_reduce(result);
   n <= result(15);
   C <= result;
   cout <= calc(16);
end;
