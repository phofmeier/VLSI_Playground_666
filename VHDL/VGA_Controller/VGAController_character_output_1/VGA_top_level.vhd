----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:53:12 06/18/2017 
-- Design Name: 
-- Module Name:    VGA_top_level - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VGA_top_level is
port(
      clk   : in std_logic;									
		reset : in std_logic;										
		hsync : out  std_logic;								
      vsync : out  std_logic;								
      red   : out  std_logic;								
      green : out  std_logic;								
      blue  : out  std_logic;								 	
		we    : in  std_logic;					
		databus    : in  STD_LOGIC_VECTOR (15 downto 0);	
		addressbus : in  STD_LOGIC_VECTOR (11 downto 0));
end VGA_top_level;

architecture Behavioral of VGA_top_level is


component timing_gen 
   port ( hsync      : out std_logic;
          vsync      : out std_logic;
          pixel_clk  : out std_logic;
          pixel_en   : out std_logic;
          pixel_top  : out std_logic;
          pixel_left : out std_logic;
          clk        : in  std_logic;
          reset      : in  std_logic );
end component;

component image_gen
	port(pixel_en    : in std_logic;
			red        : out std_logic;
			blue		  : out std_logic;
			green      : out std_logic;
			pixel_clk  : in std_logic;
			clk        : in std_logic;
			pixel      : in std_logic);
end component;

component characterRAM 
port (pixel_clk     : in std_logic;
		clk           : in STD_LOGIC;
		we            : in  STD_LOGIC;
		pixel_en      : in STD_LOGIC;
		pixel_left    : in STD_LOGIC;
		address_read  : in std_logic_vector(11 downto 0);
		addressbus   : in std_logic_vector(11 downto 0);
		databus       : in  STD_LOGIC_VECTOR (15 downto 0);
		dataout       : out STD_LOGIC_VECTOR (15 downto 0)); 
end component;

component characterROM 
port( pixel_clk: in std_logic;
		pixel_en : in std_logic;
		data_font: in std_logic_vector(11 downto 0);
	   pixel    : out std_logic);
end component;

component char_buffer 
port(dataout  : in STD_LOGIC_VECTOR (15 downto 0);
	  pixel_clk: in STD_LOGIC;
	  char     : in STD_LOGIC;
	  height   : in STD_LOGIC_VECTOR(3 downto 0);
	  data_font: out STD_LOGIC_VECTOR(11 downto 0));
end component;

component read_address_generation 
	port(pixel_clk    : in std_logic;
		  address_read : out std_logic_vector (11 downto 0);
		  char	      : out std_logic;
		  height       : out std_logic_vector(3 downto 0);
		  pixel_en     : in std_logic;
		  pixel_left   : in std_logic;
		  pixel_top    : in std_logic);
end component;

--component address_mux
--   Port ( addressbus   : in  STD_LOGIC_VECTOR (11 downto 0);
--          we           : in  STD_LOGIC;
--			 pixel_en     : in  STD_LOGIC;
--			 pixel_clk    : in STD_LOGIC;
--          address_read : in  STD_LOGIC_VECTOR (11 downto 0);
--          address      : out  STD_LOGIC_VECTOR(11 downto 0));
--end component;


signal pixel, pixel_clk, pixel_en, char,pixel_left,pixel_top: std_logic;
signal address: std_logic_vector( 11 downto 0);
signal dataout: std_logic_vector( 15 downto 0);
signal data_font : std_logic_vector( 11 downto 0);
signal height: std_logic_vector(3 downto 0);
signal address_read: std_logic_vector( 11 downto 0);


begin 



uut1: timing_gen    port map (
      clk         => clk,
      reset       => reset,
      hsync       => hsync,
      vsync       => vsync,
      pixel_clk   => pixel_clk,
      pixel_en    => pixel_en,
      pixel_top   => pixel_top,  -- comes one cycle before pixel_en
      pixel_left  => pixel_left  -- comes one cycle before pixel_en
   );
uut2: image_gen  port map(
			pixel_en   => pixel_en,
			clk        => clk,
			pixel_clk  => pixel_clk,
			pixel      => pixel,
			red        => red,
			blue		  => blue,
			green      => green
			);
--uut3: address_mux port map(
--			we           =>we,
--			pixel_en     =>pixel_en,
--			pixel_clk    => pixel_clk,
--			addressbus   => addressbus,
--			address_read => address_read,
--			address      => address);

uut4:characterRAM port map(
		pixel_clk  => pixel_clk,
		clk        => clk,
		we         => we,
		pixel_en   => pixel_en,
		pixel_left => pixel_left,
		address_read  => address_read,
		addressbus  => addressbus,
		databus    => databus,
		dataout    => dataout);
		
uut5:characterROM port map(
		pixel_clk => pixel_clk,
		pixel_en  => pixel_en,
		data_font => data_font,
	   pixel     => pixel);

uut6:char_buffer port map(
	  dataout  => dataout,
	  pixel_clk=> pixel_clk,
	  char=> char,
	  height   => height,
	  data_font=> data_font);
	  
uut7: read_address_generation port map( 
		  pixel_clk    => pixel_clk,
		  address_read => address_read,
		  char    	   => char,
		  height       => height,
		  pixel_en     => pixel_en,
		  pixel_top    => pixel_top,
		  pixel_left   => pixel_left);


end Behavioral;

