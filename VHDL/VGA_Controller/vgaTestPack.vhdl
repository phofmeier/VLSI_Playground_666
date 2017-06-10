-------------------------------------------------------------------------------
-- Title      : BMP Package
-- Project    : 
-------------------------------------------------------------------------------
-- File       : sim_bmppack.vhd
-- Author     : Kest
-- Company    : 
-- Created    : 2006-12-05
-- Last update: 2009-05-08
-- Platform   : ModelSIM 6.0
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2006 by Kest
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2006-12-05  1.0      kest            Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


-------------------------------------------------------------------------------
package sim_bmppack is

  -- maximale Gr��e des Speichers
  constant cMAX_X         : integer := 1300;
  constant cMAX_Y         : integer := 1300;
  constant cBytesPerPixel : integer := 3;

  constant cMaxMemSize : integer := cMAX_X * cMAX_Y * cBytesPerPixel;

  subtype file_element is std_logic_vector(7 downto 0);
  type    mem_array is array(cMaxMemSize downto 0) of file_element;
  type    header_array is array(53 downto 0) of file_element;


  procedure ReadFile(FileName  : in string);
  procedure ReadHeader;
  procedure WriteFile(FileName : in string);

  procedure ReadByteFromMemory (adr : in integer; variable data : out std_logic_vector(7 downto 0));
  procedure WriteByteToMemory (adr  : in integer; variable data : in std_logic_vector(7 downto 0));

  function GetWidth(header        : in  header_array) return integer;
  procedure GetWidth(signal width : out integer);

  function GetHeigth(header         : in  header_array) return integer;
  procedure GetHeigth(signal height : out integer);

  procedure GetPixel (x : in integer; y : in integer; signal data : out std_logic_vector(23 downto 0));
  procedure SetPixel (x : in integer; y : in integer; signal data : in std_logic_vector(23 downto 0));

  type BMPHeaderArray is array (0 to 53) of std_logic_vector(7 downto 0);  -- array definition for font ROM

  constant BMPHeader : BMPHeaderArray := ( X"42", X"4d", X"36", X"10", X"0e", X"00", X"00", X"00", X"00", X"00", X"36", X"00", X"00", X"00", X"28", X"00", X"00", X"00", X"80", X"02", X"00", X"00", X"e0", X"01", X"00", X"00", X"01", X"00", X"18", X"00", X"00", X"00", X"00", X"00", X"00", X"10", X"0e", X"00", X"13", X"0b", X"00", X"00", X"13", X"0b", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00" );
  
end package sim_bmppack;


-------------------------------------------------------------------------------
-- Package body 
-------------------------------------------------------------------------------
package body sim_bmppack is


  -----------------------------------------------------------------------------
  -- 
  -----------------------------------------------------------------------------

  shared variable memory_in  : mem_array;
  shared variable memory_out : mem_array;

  shared variable header : header_array;

  shared variable pImageSize   : integer;
  shared variable pImageWidth  : integer;
  shared variable pImageHeight : integer;



  -----------------------------------------------------------------------------
  -- This code reads a raw binary file one byte at a time.
  -----------------------------------------------------------------------------
  procedure ReadFile(FileName : in string) is

    variable next_vector : character;
    variable actual_len  : integer := 1;
    variable index       : integer := 0;
    variable next_int : integer := 0;
    type     bit_vector_file is file of character;
    file read_file       : bit_vector_file; -- open read_mode is FileName;

  begin
    report "Read File";
    report FileName;

    index := 0;

    ---------------------------------------------------------------------------
    -- Header einlesen
    ---------------------------------------------------------------------------

    report "Read Header";
    file_open(read_file, FileName, read_mode);
    
    for i in 0 to 53 loop
      read(read_file, next_vector);
      header(index) := std_logic_vector(conv_unsigned( character'pos(next_vector) , 8));
      index         := index + 1;
    end loop;

    pImageWidth  := GetWidth(header);
    pImageHeight := GetHeigth(header);

    assert false report "Width: "&integer'image(pImageWidth)&" Height: "&integer'image(pImageHeight) severity note;
    
    pImageSize   := pImageWidth * pImageHeight;

    report "Read Image";
    index := 0;
    while not endfile(read_file) loop
      read(read_file, next_vector);
      memory_in(index)  := std_logic_vector(conv_unsigned( character'pos(next_vector) , 8));
      memory_out(index) := x"45";
      index             := index + 1;
      
    end loop;
    file_close(read_file);
    report "Okay";
  end ReadFile;

  procedure ReadHeader is
    variable index : integer := 0;
  begin
    ---------------------------------------------------------------------------
    -- Header lesen
    ---------------------------------------------------------------------------

    -- report "Read Header";
    
    for i in 0 to 53 loop
      header(index) := BMPHeader(index);
      index         := index + 1;
    end loop;

    pImageWidth  := GetWidth(header);
    pImageHeight := GetHeigth(header);

    -- assert false report "Width: "&integer'image(pImageWidth)&" Height: "&integer'image(pImageHeight) severity note;
    
    pImageSize   := pImageWidth * pImageHeight;

    -- report "Okay";
  end ReadHeader;


  -----------------------------------------------------------------------------
  -- Read one byte from Memory
  -----------------------------------------------------------------------------
  procedure ReadByteFromMemory (adr : in integer; variable data : out std_logic_vector(7 downto 0)) is
  begin
    data := memory_in(adr);
  end ReadByteFromMemory;


  -----------------------------------------------------------------------------
  -- Pixel Operationen
  -----------------------------------------------------------------------------

  procedure GetPixel (x : in integer; y : in integer; signal data : out std_logic_vector(23 downto 0)) is
  begin
    if x >= 0 and x < cMAX_X and y >= 0 and y < cMAX_Y then
      data(23 downto 16) <= memory_in(x*3 + 3*y*GetWidth(header));
      data(15 downto 8)  <= memory_in(x*3+1 + 3*y*GetWidth(header));
      data(7 downto 0)   <= memory_in(x*3+2 + 3*y*GetWidth(header));
    end if;
  end GetPixel;

  procedure SetPixel (x : in integer; y : in integer; signal data : in std_logic_vector(23 downto 0)) is
  begin
    if x >= 0 and x < cMAX_X and y >= 0 and y < cMAX_Y then
      memory_out(x*3+y*(GetWidth(header)*3))   := data(23 downto 16);
      memory_out(x*3+1+y*(GetWidth(header)*3)) := data(15 downto 8);
      memory_out(x*3+2+y*(GetWidth(header)*3)) := data(7 downto 0);
    end if;
  end SetPixel;



  -----------------------------------------------------------------------------
  -- Write one byte to Memory
  -----------------------------------------------------------------------------
  procedure WriteByteToMemory (adr : in integer; variable data : in std_logic_vector(7 downto 0)) is
  begin
    memory_out(adr) := data;
  end WriteByteToMemory;

  -- Get Width of Image
  function GetWidth(header : in header_array) return integer is
    variable comb_num : std_logic_vector(31 downto 0);
  begin
    comb_num := header(21) & header(20) & header(19) & header(18);
    return conv_integer(comb_num(30 downto 0));
  end function GetWidth;

  procedure GetWidth(signal width : out integer) is
  begin
    width <= pImageWidth;
  end GetWidth;

  -- Get Height of Image
  function GetHeigth(header : in header_array) return integer is
    variable comb_num : std_logic_vector(31 downto 0);
  begin
    comb_num := header(25) & header(24) & header(23) & header(22);
    return conv_integer(comb_num(30 downto 0));
  end function GetHeigth;

  procedure GetHeigth(signal height : out integer) is
  begin
    height <= pImageHeight;
  end GetHeigth;

  -----------------------------------------------------------------------------
  -- This code write a raw binary file one byte at a time.
  -----------------------------------------------------------------------------
  procedure WriteFile(FileName : in string) is

    variable next_vector : character;
    variable index       : integer := 0;
    type     char_file is file of character;
    file write_file      : char_file open write_mode is FileName;

  begin
    report "Write Output File...";
    report FileName;

    -- report "write Header";
    index := 0;
    for i in 0 to 53 loop
      next_vector := character'val(conv_integer(header(index)));
      write(write_file, next_vector);
      index       := index + 1;
    end loop;


    -- report "write Image";
    index := 0;
    while index < pImageSize*3 loop
      next_vector := character'val(conv_integer(memory_out(index)));
      write(write_file, next_vector);
      index       := index + 1;
    end loop;

    -- report "Okay";

  end WriteFile;

  
end sim_bmppack;







library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.sim_bmppack.all;


entity vgaTester is

  generic (
    dumpScreen : integer := 1 );
  
  port (
    vsync : in std_logic;
    hsync : in std_logic;
    red   : in real;
    green : in real;
    blue  : in real);

end vgaTester;


architecture behavior of vgaTester is

  type syncstates is (NOTINIT, SYNCPULSE, RISE, BACKPORCH, DISP, FRONTPORCH, FALL);
  signal current_mode_VSYNC : syncstates := NOTINIT;
  signal current_mode_HSYNC : syncstates := NOTINIT;
  signal hsync_start : std_logic := '0';

  constant SCREENHEIGHT : integer := 480;

  constant pixelCLK : time := 40 ns;    -- clock period of pixel clock
  constant HSYNC_RFTIME : time := 20 ps;  -- time window for the signal to rise or to fall...
  constant HSYNC_PW : time := 96*pixelCLK;
  constant HSYNC_FP : time := 16*pixelCLK;
  constant HSYNC_BP : time := 48*pixelCLK;
  constant HSYNC_DISP : time := 640*pixelCLK;

  constant HSYNC_PT : time := 800*pixelCLK;

  constant VSYNC_RFTIME : time := 20 ps;
  constant VSYNC_PW : time := 2*HSYNC_PT;
  constant VSYNC_FP : time := 10*HSYNC_PT;
  constant VSYNC_BP : time := 29*HSYNC_PT;
  constant VSYNC_DISP : time := 480*HSYNC_PT;

  signal valueRGB : std_logic_vector(23 downto 0) := (others=>'0');
  
begin  -- behavior

  -- purpose: check if vsync signal timing is correct
  -- type   : combinational
  -- inputs : vsync
  -- outputs: 
  checkVSYNC1: process
  begin  -- process checkVSYNC

--     VSYNC_FIRST: loop
--      assert false  report "in vsync_first loop" severity note;
--      wait on vsync;
--      assert vsync = '1' report "vsync is 0" severity note;
--      assert vsync = '0' report "vsync is 1" severity note;
--      if vsync = '0' then
--        assert false report "vsync" severity note;
--        exit VSYNC_FIRST;
--      end if;
--    end loop;
    
    wait until falling_edge(vsync);
    hsync_start <= '1';
    wait for VSYNC_RFTIME/2;
    assert false report "starting surveillance of vsync..." severity note;

    VSYNC_LOOP: loop
      current_mode_VSYNC <= SYNCPULSE;
      assert vsync = '0' report "vsync not 0 during vsync pulse!" severity error;
      assert red = 0.0 report "red not 0 during vsync pulse!" severity error;
      assert green = 0.0 report "green not 0 during vsync pulse!" severity error;
      assert blue = 0.0 report "blue not 0 during vsync pulse!" severity error;
      wait for VSYNC_PW-VSYNC_RFTIME;
      current_mode_VSYNC <= RISE;
      wait for VSYNC_RFTIME;
      current_mode_VSYNC <= BACKPORCH;
      assert vsync = '1' report "vsync not 1 during vsync backporch!" severity error;
      assert red = 0.0 report "red not 0 during vsync backporch!" severity error;
      assert green = 0.0 report "green not 0 during vsync backporch!" severity error;
      assert blue = 0.0 report "blue not 0 during vsync backporch!" severity error;
      wait for VSYNC_BP-VSYNC_RFTIME;
      current_mode_VSYNC <= DISP;
      assert vsync = '1' report "vsync not 1 during vsync display time!" severity error;
      wait for VSYNC_DISP+VSYNC_RFTIME;  -- add RFTIME here so that display
                                         -- signals have time to rise/fall
      current_mode_VSYNC <= FRONTPORCH;
      assert vsync = '1' report "vsync not 1 during vsync frontporch!" severity error;
      assert red = 0.0 report "red not 0 during vsync frontporch!" severity error;
      assert green = 0.0 report "green not 0 during vsync frontporch!" severity error;
      assert blue = 0.0 report "blue not 0 during vsync frontporch!" severity error;
      wait for VSYNC_FP-VSYNC_RFTIME;
      current_mode_VSYNC <= FALL;
      wait for VSYNC_RFTIME;     
    end loop;

  end process checkVSYNC1;

  -- purpose: when there is a transition on vsync, make sure it is allowed
  -- type   : combinational
  -- inputs : vsync
  -- outputs: 
  checkVSYNC2: process (vsync)
  begin  -- process checkVSYNC2
    case current_mode_VSYNC is
      when SYNCPULSE =>
        assert vsync = '0' report "vsync not 0 during vsync pulse!" severity error;
      when BACKPORCH =>
        assert vsync = '1' report "vsync not 1 during vsync backporch!" severity error;
      when FRONTPORCH =>
        assert vsync = '1' report "vsync not 1 during vsync frontporch!" severity error;
      when DISP =>
        assert vsync = '1' report "vsync not 1 during vsync display time!" severity error;
      when others => null;
    end case;
  end process checkVSYNC2;

  -- purpose: ckeck that red, green and blue signals are 0 when they are required to be that due to VSYNC state
  -- type   : combinational
  -- inputs : red, green, blue
  -- outputs: 
  checkVSYNC3: process (red, green, blue)
  begin  -- process checkVSYNC3
        case current_mode_VSYNC is
      when SYNCPULSE =>
        assert red = 0.0 report "red not 0 during vsync pulse!" severity error;
        assert green = 0.0 report "green not 0 during vsync pulse!" severity error;
        assert blue = 0.0 report "blue not 0 during vsync pulse!" severity error;
      when BACKPORCH =>
        assert red = 0.0 report "red not 0 during vsync backporch!" severity error;
        assert green = 0.0 report "green not 0 during vsync backporch!" severity error;
        assert blue = 0.0 report "blue not 0 during vsync backporch!" severity error;
      when FRONTPORCH =>
        assert red = 0.0 report "red not 0 during vsync frontporch!" severity error;
        assert green = 0.0 report "green not 0 during vsync frontporch!" severity error;
        assert blue = 0.0 report "blue not 0 during vsync frontporch!" severity error;
      when others => null;
    end case;
  end process checkVSYNC3;
  
  -- purpose: check if hsync signal timing is correct
  -- type   : combinational
  -- inputs : vsync
  -- outputs: 
  checkHSYNC: process
  begin  -- process checkVSYNC

    HSYNC_FIRST: loop
      wait on hsync_start;
      if hsync_start = '1' then
        exit HSYNC_FIRST;
      end if;
    end loop;

    wait for HSYNC_RFTIME/2;
    
    assert false report "starting surveillance of hsync..." severity note;
   
    HSYNC_LOOP: loop
      current_mode_HSYNC <= FRONTPORCH;
      assert hsync = '1' report "hsync not 1 during hsync frontporch!" severity error;
      assert red = 0.0 report "red not 0 during hsync frontporch!" severity error;
      assert green = 0.0 report "green not 0 during hsync frontporch!" severity error;
      assert blue = 0.0 report "blue not 0 during hsync frontporch!" severity error;
      wait for HSYNC_FP-HSYNC_RFTIME;
      current_mode_HSYNC <= FALL;
      wait for HSYNC_RFTIME;
      current_mode_HSYNC <= SYNCPULSE;
      assert hsync = '0' report "hsync not 0 during hsync pulse!" severity error;
      assert red = 0.0 report "red not 0 during hsync pulse!" severity error;
      assert green = 0.0 report "green not 0 during hsync pulse!" severity error;
      assert blue = 0.0 report "blue not 0 during hsync pulse!" severity error;
      wait for HSYNC_PW-HSYNC_RFTIME;
      current_mode_HSYNC <= RISE;
      wait for HSYNC_RFTIME;
      current_mode_HSYNC <= BACKPORCH;
      assert hsync = '1' report "hsync not 1 during hsync backporch!" severity error;
      assert red = 0.0 report "red not 0 during hsync backporch!" severity error;
      assert green = 0.0 report "green not 0 during hsync backporch!" severity error;
      assert blue = 0.0 report "blue not 0 during hsync backporch!" severity error;
      wait for HSYNC_BP-HSYNC_RFTIME;
      current_mode_HSYNC <= DISP;
      assert hsync = '1' report "hsync not 1 during hsync display time!" severity error;
      wait for HSYNC_DISP+HSYNC_RFTIME;  -- add RFTIME here so that display
                                         -- signal can rise/fall
    end loop;

  end process checkHSYNC;

  -- purpose: when there is a transition on hsync, make sure it is allowed
  -- type   : combinational
  -- inputs : hsync
  -- outputs: 
  checkHSYNC2: process (hsync)
  begin  -- process checkHSYNC2
    case current_mode_HSYNC is
      when SYNCPULSE =>
        assert hsync = '0' report "hsync not 0 during hsync pulse!" severity error;
      when BACKPORCH =>
        assert hsync = '1' report "hsync not 1 during hsync backporch!" severity error;
      when FRONTPORCH =>
        assert hsync = '1' report "hsync not 1 during hsync frontporch!" severity error;
      when DISP =>
        assert hsync = '1' report "hsync not 1 during hsync display time!" severity error;
      when others => null;
    end case;
  end process checkHSYNC2;

  -- purpose: ckeck that red, green and blue signals are 0 when they are required to be that due to HSYNC state
  -- type   : combinational
  -- inputs : red, green, blue
  -- outputs: 
  checkHSYNC3: process (red, green, blue)
  begin  -- process checkHSYNC3
    case current_mode_HSYNC is
      when SYNCPULSE =>
        assert red = 0.0 report "red not 0 during hsync pulse!" severity error;
        assert green = 0.0 report "green not 0 during hsync pulse!" severity error;
        assert blue = 0.0 report "blue not 0 during hsync pulse!" severity error;
      when BACKPORCH =>
        assert red = 0.0 report "red not 0 during hsync backporch!" severity error;
        assert green = 0.0 report "green not 0 during hsync backporch!" severity error;
        assert blue = 0.0 report "blue not 0 during hsync backporch!" severity error;
      when FRONTPORCH =>
        assert red = 0.0 report "red not 0 during hsync frontporch!" severity error;
        assert green = 0.0 report "green not 0 during hsync frontporch!" severity error;
        assert blue = 0.0 report "blue not 0 during hsync frontporch!" severity error;
      when others => null;
    end case;
  end process checkHSYNC3;

  -- purpose: check that vsync ever appears within the first 20 ms
  -- type   : combinational
  -- inputs : vsync
  -- outputs: 
  checkVSYNCBegin: process
  begin  -- process checkVSYNCBegin
    wait for 20 ms;
    assert current_mode_VSYNC /= NOTINIT report "No VSYNC synchronization pulse appeared within the first 20ms of simulation time!" severity error;
    wait;
  end process checkVSYNCBegin;


  -- purpose: write out image data to file "screenDump.bmp"
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  BMPWriteOut : process

    variable valueR, valueG, valueB : std_logic_vector(7 downto 0);
    variable x,y : integer := 0;
    
  begin  -- process BMPWriteOut
    if dumpScreen = 1 then
      -- ReadFile("scrdmp.bmp");
      ReadHeader;

      BMPWOLoop : loop

        wait until current_mode_VSYNC = DISP;

        y := SCREENHEIGHT-1;

        BMPWOScreen : loop

          if current_mode_VSYNC /= DISP then
            exit BMPWOScreen;
          end if;

          wait until current_mode_HSYNC = DISP;

          x := 0;
          wait for pixelCLK/2;
          BMPWOLine : loop
            if current_mode_HSYNC /= DISP then
              exit BMPWOLine;
            end if;

            valueR := conv_std_logic_vector(integer(red*255.0), 8);
            valueG := conv_std_logic_vector(integer(green*255.0), 8);
            valueB := conv_std_logic_vector(integer(blue*255.0), 8);
            valueRGB <= valueB & valueG & valueR;

            wait for pixelCLK;

            SetPixel(x, y, valueRGB);
            x := x+1;

          end loop;

          y := y-1;
          
        end loop;

        WriteFile("screenDump.bmp");

      end loop;
      
      
    else
      wait;
    end if;

  end process BMPWriteOut;
  

end behavior;




library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;


entity vgaTesterDigInterface is
  
  port (
    vsync : in std_logic;
    hsync : in std_logic;
    red   : in std_logic;
    green : in std_logic;
    blue  : in std_logic);

end vgaTesterDigInterface;

architecture strucutral of vgaTesterDigInterface is

  component vgaTester
    port (
      vsync : in std_logic;
      hsync : in std_logic;
      red   : in real;
      green : in real;
      blue  : in real);
  end component;
  
  signal pixelRreal, pixelGreal, pixelBreal : real;

begin  -- structural

  pixelRreal <= real(conv_integer(red));
  pixelGreal <= real(conv_integer(green));
  pixelBreal <= real(conv_integer(blue));
  

  vgaTester_1: vgaTester
    port map (
      vsync => vsync,
      hsync => hsync,
      red   => pixelRreal,
      green => pixelGreal,
      blue  => pixelBreal );
end strucutral;
