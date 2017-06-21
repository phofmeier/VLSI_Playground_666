--Read comments in Line 322 bevore Hardwaretest or simulation


----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:43:25 05/26/2017 
-- Design Name: 
-- Module Name:    PS2-Controller - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_MISC.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PS2_Controller is
    Port ( OE : in  STD_LOGIC;
           databus : out  STD_LOGIC_VECTOR (7 downto 0);
           interrupt : out  STD_LOGIC;
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           PS2clk : in  STD_LOGIC;
           PS2data : in  STD_LOGIC;
			  LED :  out std_logic_vector (7 downto 0)); --LED for debugging
end PS2_Controller;

architecture Behavioral of PS2_Controller is

--definition of the states for the state machine
type STATES is (RST, START, 
					START_BIT, WAIT_START_BIT,
--					BIT_IN, WAIT_STATE,
					BIT_0, WAIT_BIT_0, 
					BIT_1, WAIT_BIT_1,
					BIT_2, WAIT_BIT_2,
					BIT_3, WAIT_BIT_3,
					BIT_4, WAIT_BIT_4,
					BIT_5, WAIT_BIT_5,
					BIT_6, WAIT_BIT_6,
					BIT_7, WAIT_BIT_7,
					BIT_P, WAIT_BIT_P,
					STOP_BIT, WAIT_STOP_BIT,
					LAST_HIGH, CHECK_PARITY,
					F0_DETECT, BRACKET_DETECT,
					CHECK_BYTE,
					DATA_ON_BUS,
					DATA_OFF_BUS);
signal state : STATES;
signal data_sig : std_logic_vector(7 downto 0); --input register from Keyboard
signal data_convert_sig : std_logic_vector(7 downto 0); --converted data_sig
signal data_output : std_logic_vector(7 downto 0);
signal parity_sig : std_logic;
signal check_parity_sig : std_logic;
signal idx_sig, idx_next_sig : integer range 0 to 7 := 0;
signal counter_sig : integer range 0 to 16 := 0;
signal shift_reg_sig : STD_LOGIC_VECTOR(7 downto 0) := X"00";
signal clock_div_sig : std_logic := '0';
signal led_sig : std_logic_vector(7 downto 0);
signal F0_sig : std_logic; --1: next data on bus 0: throw next data away
signal shift_sig : std_logic; --1: shift is presst

--Input codes from PS2-Keyboard
constant key_1 : std_logic_vector(7 downto 0) := "00010110";
constant key_2 : std_logic_vector(7 downto 0) := "00011110";
constant key_3 : std_logic_vector(7 downto 0) := "00100110";
constant key_4 : std_logic_vector(7 downto 0) := "00100101";
constant key_5 : std_logic_vector(7 downto 0) := "00101110";
constant key_6 : std_logic_vector(7 downto 0) := "00110110";
constant key_7 : std_logic_vector(7 downto 0) := "00111101";
constant key_8 : std_logic_vector(7 downto 0) := "00111110";
constant key_9 : std_logic_vector(7 downto 0) := "01000110";
constant key_0 : std_logic_vector(7 downto 0) := "01000101";
constant key_add : std_logic_vector(7 downto 0) := "01111001";
constant key_sub : std_logic_vector(7 downto 0) := "01111011";
constant key_mul : std_logic_vector(7 downto 0) := "01111100";
constant key_div : std_logic_vector(7 downto 0) := "01001010";
constant key_enter : std_logic_vector(7 downto 0) := "01011010";

constant key_0_KP : std_logic_vector(7 downto 0) := X"70";
constant key_1_KP : std_logic_vector(7 downto 0) := X"69";
constant key_2_KP : std_logic_vector(7 downto 0) := X"72";
constant key_3_KP : std_logic_vector(7 downto 0) := X"7A";
constant key_4_KP : std_logic_vector(7 downto 0) := X"6B";
constant key_5_KP : std_logic_vector(7 downto 0) := X"73";
constant key_6_KP : std_logic_vector(7 downto 0) := X"74";
constant key_7_KP : std_logic_vector(7 downto 0) := X"6C";
constant key_8_KP : std_logic_vector(7 downto 0) := X"75";
constant key_9_KP : std_logic_vector(7 downto 0) := X"7D";

--Converted codes to the Processor
constant conv_1 : std_logic_vector(7 downto 0) := "00000001";
constant conv_2 : std_logic_vector(7 downto 0) := "00000010";
constant conv_3 : std_logic_vector(7 downto 0) := "00000011";
constant conv_4 : std_logic_vector(7 downto 0) := "00000100";
constant conv_5 : std_logic_vector(7 downto 0) := "00000101";
constant conv_6 : std_logic_vector(7 downto 0) := "00000110";
constant conv_7 : std_logic_vector(7 downto 0) := "00000111";
constant conv_8 : std_logic_vector(7 downto 0) := "00001000";
constant conv_9 : std_logic_vector(7 downto 0) := "00001001";
constant conv_0 : std_logic_vector(7 downto 0) := "00000000";
constant conv_add : std_logic_vector(7 downto 0) := "10000001";
constant conv_sub : std_logic_vector(7 downto 0) := "10000010";
constant conv_mul : std_logic_vector(7 downto 0) := "10000011";
constant conv_div : std_logic_vector(7 downto 0) := "10000100";
constant conv_enter : std_logic_vector(7 downto 0) := "11101110";
constant conv_bracket_left : std_logic_vector(7 downto 0) := X"0C";
constant conv_bracket_right : std_logic_vector(7 downto 0) := X"C0";


begin
	process (clk, reset)
	begin
		if reset = '1' then
			state <= START;
			databus <= "ZZZZZZZZ";
			parity_sig <= '0';
			check_parity_sig <= '0';
			data_sig <= "00000000";
			F0_sig <= '0';
		elsif rising_edge (clk) then
			case state is
				when RST =>
					state <= START;
				when START =>
					LED <= X"F0";
					led_sig <= X"00";
					--if ps2clk = '0' then
					if shift_reg_sig(6) = '0' and shift_reg_sig(1) = '1' then
						data_sig <= "00000000";
						check_parity_sig <= '0';
						state <= START_BIT;
					end if;
				when START_BIT =>
					LED <= X"01";
					led_sig <= X"01";
					--if ps2clk = '1' then
					if shift_reg_sig(6) = '1' and shift_reg_sig(1) = '0' then
						state <= WAIT_BIT_0;
						LED <= X"02";
						led_sig <= X"02";
					end if;
				
				when WAIT_BIT_0 =>
					--if PS2clk = '0' then
					if shift_reg_sig(6) = '0' and shift_reg_sig(1) = '1' then
						LED <= X"04";
						state <= BIT_1;
						data_sig(0) <= PS2data;
					end if;
				when BIT_1 =>
					--if PS2clk = '1' then
					if shift_reg_sig(6) = '1' and shift_reg_sig(1) = '0' then
						LED <= X"05";
						check_parity_sig <= check_parity_sig xor data_sig(0);
						state <= WAIT_BIT_1;
					end if;
				when WAIT_BIT_1 =>
					--if PS2clk = '0' then
					if shift_reg_sig(6) = '0' and shift_reg_sig(1) = '1' then
						LED <= X"06";
						state <= BIT_2;
						data_sig(1) <= PS2data;
					end if;
				when BIT_2 =>
					--if PS2clk = '1' then
					if shift_reg_sig(6) = '1' and shift_reg_sig(1) = '0' then
						LED <= X"07";
						check_parity_sig <= check_parity_sig xor data_sig(1);
						state <= WAIT_BIT_2;
					end if;
				when WAIT_BIT_2 =>
					--if PS2clk = '0' then
					if shift_reg_sig(6) = '0' and shift_reg_sig(1) = '1' then
						LED <= X"08";
						state <= BIT_3;
						data_sig(2) <= PS2data;
					end if;
				when BIT_3 =>
					--if PS2clk = '1' then
					if shift_reg_sig(6) = '1' and shift_reg_sig(1) = '0' then
						LED <= X"09";
						check_parity_sig <= check_parity_sig xor data_sig(2);
						state <= WAIT_BIT_3;
					end if;
				when WAIT_BIT_3 =>
					--if PS2clk = '0' then
					if shift_reg_sig(6) = '0' and shift_reg_sig(1) = '1' then
						LED <= X"0A";
						state <= BIT_4;
						data_sig(3) <= PS2data;
					end if;
				when BIT_4 =>
					--if PS2clk = '1' then
					if shift_reg_sig(6) = '1' and shift_reg_sig(1) = '0' then
						LED <= X"0B";
						check_parity_sig <= check_parity_sig xor data_sig(3);
						state <= WAIT_BIT_4;
					end if;
				when WAIT_BIT_4 =>
					--if PS2clk = '0' then
					if shift_reg_sig(6) = '0' and shift_reg_sig(1) = '1' then
						LED <= X"0C";
						state <= BIT_5;
						data_sig(4) <= PS2data;
					end if;
				when BIT_5 =>
					--if PS2clk = '1' then
					if shift_reg_sig(6) = '1' and shift_reg_sig(1) = '0' then
						LED <= X"0D";
						check_parity_sig <= check_parity_sig xor data_sig(4);
						state <= WAIT_BIT_5;
					end if;
				when WAIT_BIT_5 =>
					--if PS2clk = '0' then
					if shift_reg_sig(6) = '0' and shift_reg_sig(1) = '1' then
						LED <= X"0E";
						state <= BIT_6;
						data_sig(5) <= PS2data;
					end if;
				when BIT_6 =>
					--if PS2clk = '1' then
					if shift_reg_sig(6) = '1' and shift_reg_sig(1) = '0' then
						LED <= X"0F";
						check_parity_sig <= check_parity_sig xor data_sig(5);
						state <= WAIT_BIT_6;
					end if;
				when WAIT_BIT_6 =>
					--if PS2clk = '0' then
					if shift_reg_sig(6) = '0' and shift_reg_sig(1) = '1' then
						LED <= X"0F";
						state <= BIT_7;
						data_sig(6) <= PS2data;
					end if;
				when BIT_7 =>
					--if PS2clk = '1' then
					if shift_reg_sig(6) = '1' and shift_reg_sig(1) = '0' then
						LED <= X"10";
						check_parity_sig <= check_parity_sig xor data_sig(6);
						state <= WAIT_BIT_7;
					end if;
				when WAIT_BIT_7 =>
					--if PS2clk = '0' then
					if shift_reg_sig(6) = '0' and shift_reg_sig(1) = '1' then
						LED <= X"11";
						data_sig(7) <= PS2data;
						
						state <= BIT_P;
					end if;
				when BIT_P =>
					--if PS2clk = '1' then
					if shift_reg_sig(6) = '1' and shift_reg_sig(1) = '0' then
						LED <= X"12";
						check_parity_sig <= check_parity_sig xor data_sig(7);
						state <= WAIT_BIT_P;
					end if;

				-- Parity Bit
				when WAIT_BIT_P =>
					LED <= X"11";
					--if ps2clk = '0' then
					if shift_reg_sig(6) = '0' and shift_reg_sig(1) = '1' then
						parity_sig <= PS2data;
						check_parity_sig <= not check_parity_sig;
						state <= STOP_BIT;
					end if;
				when STOP_BIT =>
					LED <= X"12";
					--if ps2clk = '1' then
					if shift_reg_sig(6) = '1' and shift_reg_sig(1) = '0' then
						state <= WAIT_STOP_BIT;
					end if;
				when WAIT_STOP_BIT =>
					LED <= X"13";
					--if ps2clk = '0' then
					if shift_reg_sig(6) = '0' and shift_reg_sig(1) = '1' then
						state <= LAST_HIGH;
					end if;
				when LAST_HIGH =>
					LED <= X"14";
					--if ps2clk = '1' then
					if shift_reg_sig(6) = '1' and shift_reg_sig(1) = '0' then
						state <= CHECK_PARITY;
					end if;
					
				--End of the Inputdatas
				
				--Check the Parity-Bit an the Data converter
				--Check the shift
				when CHECK_PARITY =>
					LED <= X"15";
					if parity_sig = check_parity_sig then
						state <= F0_DETECT;
					else 
						state <= START;
					end if;
					if data_sig = X"12" then
						--if F0_sig <= '1' then
						--	shift_sig <= '0';
						--else
							shift_sig <= '1';
						--end if;
					else
					
					end if;
				when F0_DETECT =>
					if (data_sig = X"F0") and (F0_sig = '0') then
						F0_sig <= '1';
						state <= START;
					elsif F0_sig = '1' then
						data_output <= data_convert_sig;
						state <= BRACKET_DETECT;
					else 
						state <= START;
					end if;
					
				when BRACKET_DETECT =>
					if shift_sig = '1' and data_convert_sig = X"08" then
						data_output <= conv_bracket_left;
						state <= CHECK_BYTE;
					elsif  shift_sig = '1' and data_convert_sig = X"09" then
						data_output <= conv_bracket_right;
						state <= CHECK_BYTE;
					elsif shift_sig = '1' and data_sig = X"12" then
						shift_sig <= '0';
						state <= START;
					elsif shift_sig = '0' then
						state <= CHECK_BYTE;
					else
						state <= START;
					end if;
				when CHECK_BYTE =>
					LED <= X"16";
					F0_sig <= '0';
					if data_sig = X"12" then
						--shift button is released
						shift_sig <= '0';
					
					
					end if;
					
					
		--this if loop is for the convertion of the input data.
		--not necessary for milestone 2
					--if data_convert_sig = "11111111" then
					--	state <= START;
					--else
		--for processor design: interrupt bevor databus!
						databus <= data_output;
						--databus <= data_sig;
						state <= DATA_ON_BUS;
					--end if;
				when DATA_ON_BUS =>
					LED <= X"17";
					--if OE = '1' then
						interrupt <= '1';
		--select, which data on the bus (convert or normal input)
						databus <= data_output;
						--databus <= data_sig;
						state <= DATA_OFF_BUS;
					--end if;
				when DATA_OFF_BUS =>
					LED <= X"18";
		--for Hardwaretest comment the if because there is no OE!
		--Simulation only works with if
					--if OE = '0' then
						databus <= "ZZZZZZZZ";
						interrupt <= '0';
						state <= START;
					--end if;
				when others =>
					LED <= X"EF";
					state <= RST;
				end case;
		end if;
	end process;
	
	process (clk, reset, OE, PS2clk, PS2data)
	begin
		case data_sig is
			when key_1 => 
				data_convert_sig <= conv_1;
			when key_2 => 
				data_convert_sig <= conv_2;				
			when key_3 => 
				data_convert_sig <= conv_3;
			when key_4 => 
				data_convert_sig <= conv_4;
			when key_5 => 
				data_convert_sig <= conv_5;
			when key_6 => 
				data_convert_sig <= conv_6;
			when key_7 => 
				data_convert_sig <= conv_7;
			when key_8 => 
				data_convert_sig <= conv_8;
			when key_9 => 
				data_convert_sig <= conv_9;
			when key_0 => 
				data_convert_sig <= conv_0;
			when key_1_KP => 
				data_convert_sig <= conv_1;
			when key_2_KP => 
				data_convert_sig <= conv_2;				
			when key_3_KP => 
				data_convert_sig <= conv_3;
			when key_4_KP => 
				data_convert_sig <= conv_4;
			when key_5_KP => 
				data_convert_sig <= conv_5;
			when key_6_KP => 
				data_convert_sig <= conv_6;
			when key_7_KP => 
				data_convert_sig <= conv_7;
			when key_8_KP => 
				data_convert_sig <= conv_8;
			when key_9_KP => 
				data_convert_sig <= conv_9;
			when key_0_KP => 
				data_convert_sig <= conv_0;
			when key_add => 
				data_convert_sig <= conv_add;
			when key_sub => 
				data_convert_sig <= conv_sub;
			when key_mul => 
				data_convert_sig <= conv_mul;
			when key_div => 
				data_convert_sig <= conv_div;
			when key_enter =>
				data_convert_sig <= conv_enter;
			when others =>
				data_convert_sig <= "11111111";
		end case;
	end process;
	
	process (clk)
	begin
		if rising_edge (clk) then
           shift_reg_sig(7) <= PS2clk;
           shift_reg_sig(6) <= shift_reg_sig(7);
           shift_reg_sig(5) <= shift_reg_sig(6);
           shift_reg_sig(4) <= shift_reg_sig(5);
           shift_reg_sig(3) <= shift_reg_sig(4);
           shift_reg_sig(2) <= shift_reg_sig(3);
           shift_reg_sig(1) <= shift_reg_sig(2);
           shift_reg_sig(0) <= shift_reg_sig(1);
		end if;
	end process;
							


end Behavioral;

