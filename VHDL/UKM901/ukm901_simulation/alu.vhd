
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

entity ALU is
   port (
      A, B                : in  std_logic_vector(15 downto 0);
      C                   : out std_logic_vector(15 downto 0);
      ALUFunc             : in  std_logic_vector(3 downto 0);
      nBit, shiftrot, dir : in  std_logic;
      n, z, cout          : out std_logic );
end ALU;

architecture behaviour of ALU is
   signal calc : unsigned(16 downto 0);
   signal result : std_logic_vector(15 downto 0);

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

begin
func: process(ALUFunc, nBit, shiftrot, dir, A, B)
begin
   case ALUFunc is
      -- ################################
      when ALU_ZERO =>
         calc <= (others => '0');
      when ALU_ADD =>
         calc <= unsigned('0' & A) + unsigned('0' & B);
      when ALU_SUB_AB =>
         calc <= unsigned('0' & A) - unsigned('1' & B);
      when ALU_SUB_BA =>
         calc <= unsigned('0' & B) - unsigned('1' & A);
      -- ################################
      when ALU_EQ_A =>
         calc <= unsigned('0' & A);
      when ALU_EQ_B =>
         calc <= unsigned('0' & B);
      when ALU_INC_A =>
         calc <= unsigned('0' & A) + 1;
      when ALU_INC_B =>
         calc <= unsigned('0' & B) + 1;
      -- ################################
      when ALU_AND =>
         calc <= unsigned('0' & (A and B));
      when ALU_OR =>
         calc <= unsigned('0' & (A or B));
      when ALU_XOR =>
         calc <= unsigned('0' & (A xor B));
      --when "1011" =>  -- DUNNO
      -- ################################
      when ALU_NOT_A =>
         calc <= not unsigned('0' & A);
      when ALU_NOT_B =>
         calc <= not unsigned('0' & B);
      when ALU_INV_A =>
         calc <= not unsigned('0' & A) + 1;
      when ALU_INV_B =>
         calc <= not unsigned('0' & B) + 1;
      -- ################################
      when others =>
         calc <= (others => '0');
   end case;
end process;

shrot_proc: process(ALUFunc, calc)
begin
   case ALUFunc is
      -- ################################
      when ALU_ADD | ALU_SUB_AB | ALU_SUB_BA | ALU_INC_A | ALU_INC_B =>
         cout <= calc(16);
      -- ################################
      when others =>
         cout <= '0';
   end case;
end process;

   result <= std_logic_vector(calc(15 downto 0)) when nBit = '0'
      else std_logic_vector(calc(15 downto 0) srl 1) when (shiftrot = '0' and dir = '0')
      else std_logic_vector(calc(15 downto 0) sll 1) when (shiftrot = '0' and dir = '1')
      else std_logic_vector(calc(15 downto 0) ror 1) when (shiftrot = '1' and dir = '0')
      else std_logic_vector(calc(15 downto 0) rol 1) when (shiftrot = '1' and dir = '1')
      else (others => '0');

   z <= not or_reduce(result);
   n <= result(15);
   C <= result;
end;
