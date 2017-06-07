----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 		Peter Hofmeier
-- 
-- Create Date:    16:17:27 06/07/2017 
-- Design Name: 
-- Module Name:    Calculator - Behavioral 
-- Project Name:   Calculator
-- Target Devices: Spartan 3E
-- Tool versions: 
-- Description: 	 TopLevel VHDL for complete Calculator
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Calculator is
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           hsync : out  STD_LOGIC;
           blue : out  STD_LOGIC;
           green : out  STD_LOGIC;
           red : out  STD_LOGIC;
           vsync : out  STD_LOGIC;
           ps2clk : in  STD_LOGIC;
           ps2data : in  STD_LOGIC);
end Calculator;

architecture Behavioral of Calculator is
-- Signals
signal databus_sig : std_logic_vector(15 downto 0);
signal addressbus_sig : std_logic_vector(11 downto 0);
signal addressbus_vga_sig : std_logic_vector(11 downto 0);
signal interrupt_sig : std_logic;
signal oe_sig : std_logic;
signal we_sig : std_logic;
signal oe_memory_sig : std_logic;
signal we_memory_sig : std_logic;
signal we_vga_sig : std_logic;
signal oe_ps2_sig : std_logic;

-- Constants
constant MEMORY_END_ADDR	: std_logic_vector(11 downto 0) := x"6FF";
constant VGA_START_ADDR		: std_logic_vector(11 downto 0) := x"700";
constant VGA_END_ADDR		: std_logic_vector(11 downto 0) := x"EFF";
constant PS2_ADDR				: std_logic_vector(11 downto 0) := x"FFF";



begin
	ukm910_inst: entity ukm910
		port map (	clk => clk, 
						reset => reset,
						interrupt => interrupt_sig,
						oe => oe_sig, 
						we => we_sig,
						addressbus => addressbus_sig,
						databus => databus_sig );
		
	memory_inst: entity memory
		port map (	clk => clk,
						addressbus => addressbus_sig,
						databus => databus_sig,
						we => we_memory_sig,
						oe => oe_memory_sig);
		
	PS2_Controller_inst: entity PS2_Controller
		port map (	oe => oe_ps2_sig,
						databus => databus_sig,
						interrupt => interrupt_sig,
						clk => clk,
						reset => reset,
						ps2clk => ps2clk,
						ps2data => ps2data );
		
	VGA_Controller_inst: entity VGA_Controller
		port map(	clk => clk, 
						reset => reset,
						we => we_vga_sig,
						addressbus => addressbus_vga_sig,
						databus => databus_sig,
						hsync => hsync,
						blue => blue,
						green => green,
						red => red,
						vsync => vsync);
						
	addressbus_vga_sig <= std_logic_vector(unsigned(addressbus_sig) - unsigned(VGA_START_ADDR));
	
	oe_memory_sig <= oe_sig when addressbus_sig < MEMORY_END_ADDR
		else '0';
	we_memory_sig <= we_sig when addressbus_sig < MEMORY_END_ADDR
		else '0';
		
	we_vga_sig <= we_sig when addressbus_sig > VGA_START_ADDR and addressbus_sig < VGA_END_ADDR
		else '0';
		
	oe_ps2_sig <= oe_sig when addressbus_sig = PS2_ADDR
		else '0';


end Behavioral;

