library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity LCDInterface is
  
  port (
    clk            : in  std_logic;
    reset          : in  std_logic;
    lcdData        : out std_logic_vector(3 downto 0);
    lcdRS          : out std_logic;
    lcdRW          : out std_logic;
    lcdE           : out std_logic;
    lcdReqWrite    : in  std_logic;
    lcdWriteData   : in  std_logic_vector(7 downto 0);
    lcdWriteFinish : out std_logic);

end LCDInterface;


architecture behavior of LCDInterface is
  type   writeNibbleStates is (waiting, write0, write1, write2, writeWaitEnable, write3, write4);
  signal writeState : writeNibbleStates := waiting;

  signal lcdWriteNibble : std_logic                    := '0';
  signal lcdRSNow       : std_logic                    := '0';
  signal lcdDataNibble  : std_logic_vector(3 downto 0) := (others => '0');
  signal enableClksCnt  : unsigned(3 downto 0)         := (others => '0');

  signal cntVal    : unsigned(19 downto 0)         := (others => '1');
  signal cntSet    : std_logic                     := '0';
  signal cntPreset : std_logic_vector(19 downto 0) := (others => '0');
  signal cntFinish : std_logic                     := '0';


  type   lcdWriteStates is (waitForInit, waitForRequest, writeCharUpper, writeCharLower, writeCharLowerWait, writeCharUpperWait, writeCharCheckAddr, writeCharSetLine1p1, writeCharSetLine1p2, writeCharSetLine2p1, writeCharSetLine2p2, writeCharSetLine1p1Wait, writeCharSetLine1p2Wait, writeCharSetLine2p1Wait, writeCharSetLine2p2Wait, writeCharFinished);
  signal lcdWState : lcdWriteStates := waitForInit;

  signal writeCharPos : unsigned(4 downto 0) := (others => '0');

  signal writeNibbleW   : std_logic                     := '0';
  signal lcdRSNowW      : std_logic                     := '0';
  signal lcdDataNibbleW : std_logic_vector(3 downto 0)  := (others => '0');
  signal cntSetW        : std_logic                     := '0';
  signal cntPresetW     : std_logic_vector(19 downto 0) := (others => '0');



  type lcdInitStates is (initWait0, initWait1, initWriteNibble1, initNibble1Wait, initWriteNibble2, initNibble2Wait, initWriteNibble3, initNibble3Wait, initWriteNibble4, initNibble4Wait, initWriteNibble5, initNibble5Wait, initWriteNibble6, initNibble6Wait, initWriteNibble7, initNibble7Wait, initWriteNibble8, initNibble8Wait, initWriteNibble9, initNibble9Wait, initWriteNibble10, initNibble10Wait, initWriteNibble13, initNibble13Wait, initWriteNibble14, initNibble14Wait, initWriteNibble15, initNibble15Wait, initWriteNibble16, initNibble16Wait, initFinished);

  signal lcdIState : lcdInitStates := initWait0;

  signal writeNibbleI   : std_logic                     := '0';
  signal lcdRSNowI      : std_logic                     := '0';
  signal lcdDataNibbleI : std_logic_vector(3 downto 0)  := (others => '0');
  signal cntSetI        : std_logic                     := '0';
  signal cntPresetI     : std_logic_vector(19 downto 0) := (others => '0');
  
begin  -- behavior

  -- purpose: init lcd interface
  -- type   : sequential
  -- inputs : clk, reset
  -- outputs: cntSetI, cntPresetI, writeNibbleI, lcdRSNowI, lcdDataNibbleI
  lcdInitProcess : process (clk, reset)
  begin  -- process lcdInitProcess
    if reset = '0' then                 -- asynchronous reset (active low)
      lcdIState <= initWait0;
    elsif clk'event and clk = '1' then  -- rising clock edge
      case lcdIState is
        when initWait0 =>
          cntSetI    <= '1';
          cntPresetI <= X"B71B0";
          lcdIState  <= initWait1;
        when initWait1 =>
          cntSetI <= '0';
          if cntFinish = '1' then
            lcdIState <= initWriteNibble1;
          else
            lcdIState <= initWait1;
          end if;
        when initWriteNibble1 =>
          writeNibbleI   <= '1';
          lcdRSNowI      <= '0';
          lcdDataNibbleI <= X"3";
          cntSetI        <= '1';
          cntPresetI     <= X"32130";
          lcdIState      <= initNibble1Wait;
        when initNibble1Wait =>
          writeNibbleI <= '0';
          cntSetI      <= '0';
          if cntFinish = '1' then
            lcdIState <= initWriteNibble2;
          else
            lcdIState <= initNibble1Wait;
          end if;
        when initWriteNibble2 =>
          writeNibbleI   <= '1';
          lcdRSNowI      <= '0';
          lcdDataNibbleI <= X"3";
          cntSetI        <= '1';
          cntPresetI     <= X"013F0";
          lcdIState      <= initNibble2Wait;
        when initNibble2Wait =>
          writeNibbleI <= '0';
          cntSetI      <= '0';
          if cntFinish = '1' then
            lcdIState <= initWriteNibble3;
          else
            lcdIState <= initNibble2Wait;
          end if;
        when initWriteNibble3 =>
          writeNibbleI   <= '1';
          lcdRSNowI      <= '0';
          lcdDataNibbleI <= X"3";
          cntSetI        <= '1';
          cntPresetI     <= X"00840";
          lcdIState      <= initNibble3Wait;
        when initNibble3Wait =>
          writeNibbleI <= '0';
          cntSetI      <= '0';
          if cntFinish = '1' then
            lcdIState <= initWriteNibble4;
          else
            lcdIState <= initNibble3Wait;
          end if;
        when initWriteNibble4 =>
          writeNibbleI   <= '1';
          lcdRSNowI      <= '0';
          lcdDataNibbleI <= X"2";
          cntSetI        <= '1';
          cntPresetI     <= X"00840";
          lcdIState      <= initNibble4Wait;
        when initNibble4Wait =>
          writeNibbleI <= '0';
          cntSetI      <= '0';
          if cntFinish = '1' then
            lcdIState <= initWriteNibble5;
          else
            lcdIState <= initNibble4Wait;
          end if;
        when initWriteNibble5 =>
          writeNibbleI   <= '1';
          lcdRSNowI      <= '0';
          lcdDataNibbleI <= X"2";
          cntSetI        <= '1';
          cntPresetI     <= X"0003B";
          lcdIState      <= initNibble5Wait;
        when initNibble5Wait =>
          writeNibbleI <= '0';
          cntSetI      <= '0';
          if cntFinish = '1' then
            lcdIState <= initWriteNibble6;
          else
            lcdIState <= initNibble5Wait;
          end if;
        when initWriteNibble6 =>
          writeNibbleI   <= '1';
          lcdRSNowI      <= '0';
          lcdDataNibbleI <= X"8";
          cntSetI        <= '1';
          cntPresetI     <= X"00840";
          lcdIState      <= initNibble6Wait;
        when initNibble6Wait =>
          writeNibbleI <= '0';
          cntSetI      <= '0';
          if cntFinish = '1' then
            lcdIState <= initWriteNibble7;
          else
            lcdIState <= initNibble6Wait;
          end if;
        when initWriteNibble7 =>
          writeNibbleI   <= '1';
          lcdRSNowI      <= '0';
          lcdDataNibbleI <= X"0";
          cntSetI        <= '1';
          cntPresetI     <= X"0003B";
          lcdIState      <= initNibble7Wait;
        when initNibble7Wait =>
          writeNibbleI <= '0';
          cntSetI      <= '0';
          if cntFinish = '1' then
            lcdIState <= initWriteNibble8;
          else
            lcdIState <= initNibble7Wait;
          end if;
        when initWriteNibble8 =>
          writeNibbleI   <= '1';
          lcdRSNowI      <= '0';
          lcdDataNibbleI <= X"6";
          cntSetI        <= '1';
          cntPresetI     <= X"00840";
          lcdIState      <= initNibble8Wait;
        when initNibble8Wait =>
          writeNibbleI <= '0';
          cntSetI      <= '0';
          if cntFinish = '1' then
            lcdIState <= initWriteNibble9;
          else
            lcdIState <= initNibble8Wait;
          end if;
        when initWriteNibble9 =>
          writeNibbleI   <= '1';
          lcdRSNowI      <= '0';
          lcdDataNibbleI <= X"0";
          cntSetI        <= '1';
          cntPresetI     <= X"0003B";
          lcdIState      <= initNibble9Wait;
        when initNibble9Wait =>
          writeNibbleI <= '0';
          cntSetI      <= '0';
          if cntFinish = '1' then
            lcdIState <= initWriteNibble10;
          else
            lcdIState <= initNibble9Wait;
          end if;
        when initWriteNibble10 =>
          writeNibbleI   <= '1';
          lcdRSNowI      <= '0';
          lcdDataNibbleI <= X"F";
          cntSetI        <= '1';
          cntPresetI     <= X"00840";
          lcdIState      <= initNibble10Wait;
        when initNibble10Wait =>
          writeNibbleI <= '0';
          cntSetI      <= '0';
          if cntFinish = '1' then
            lcdIState <= initWriteNibble13;
          else
            lcdIState <= initNibble10Wait;
          end if;
          
        when initWriteNibble13 =>
          writeNibbleI   <= '1';
          lcdRSNowI      <= '0';
          lcdDataNibbleI <= X"0";
          cntSetI        <= '1';
          cntPresetI     <= X"0003B";
          lcdIState      <= initNibble13Wait;
        when initNibble13Wait =>
          writeNibbleI <= '0';
          cntSetI      <= '0';
          if cntFinish = '1' then
            lcdIState <= initWriteNibble14;
          else
            lcdIState <= initNibble13Wait;
          end if;
        when initWriteNibble14 =>
          writeNibbleI   <= '1';
          lcdRSNowI      <= '0';
          lcdDataNibbleI <= X"1";
          cntSetI        <= '1';
          cntPresetI     <= X"140B4";
          lcdIState      <= initNibble14Wait;
        when initNibble14Wait =>
          writeNibbleI <= '0';
          cntSetI      <= '0';
          if cntFinish = '1' then
            lcdIState <= initWriteNibble15;
          else
            lcdIState <= initNibble14Wait;
          end if;

        when initWriteNibble15 =>
          writeNibbleI   <= '1';
          lcdRSNowI      <= '0';
          lcdDataNibbleI <= X"8";
          cntSetI        <= '1';
          cntPresetI     <= X"0003B";
          lcdIState      <= initNibble15Wait;
        when initNibble15Wait =>
          writeNibbleI <= '0';
          cntSetI      <= '0';
          if cntFinish = '1' then
            lcdIState <= initWriteNibble16;
          else
            lcdIState <= initNibble15Wait;
          end if;
        when initWriteNibble16 =>
          writeNibbleI   <= '1';
          lcdRSNowI      <= '0';
          lcdDataNibbleI <= X"0";
          cntSetI        <= '1';
          cntPresetI     <= X"00840";
          lcdIState      <= initNibble16Wait;
        when initNibble16Wait =>
          writeNibbleI <= '0';
          cntSetI      <= '0';
          if cntFinish = '1' then
            lcdIState <= initFinished;
          else
            lcdIState <= initNibble16Wait;
          end if;

          
        when initFinished =>
          lcdIState <= initFinished;
          
        when others => null;
      end case;
      
      
    end if;
  end process lcdInitProcess;



  -- purpose: write values out when requested (reqWrite), starting as soon as initialization of display is finished
  -- type   : sequential
  -- inputs : clk, reset
  -- outputs: writeNibbleW, lcdRSNowW, lcdDataNibbleW, cntSetW, cntPresetI
  lcdWriteVal : process (clk, reset)
  begin  -- process lcdWriteVal
    if reset = '0' then                 -- asynchronous reset (active low)
      lcdWriteFinish <= '0';
      writeNibbleW   <= '0';
      cntSetW        <= '0';
      writeCharPos   <= "00000";
      lcdWState      <= waitForInit;
    elsif clk'event and clk = '1' then  -- rising clock edge
      case lcdWState is
        when waitForInit =>
          if lcdIState = initFinished then
            lcdWState <= waitForRequest;
          else
            lcdWState <= waitForInit;
          end if;
        when waitForRequest =>
          lcdWriteFinish <= '0';
          if lcdReqWrite = '1' then
            lcdWState <= writeCharUpper;
          else
            lcdWState <= waitForRequest;
          end if;
        when writeCharUpper =>
          writeNibbleW   <= '1';
          lcdRSNowW      <= '1';
          lcdDataNibbleW <= lcdWriteData(7 downto 4);
          cntSetW        <= '1';
          cntPresetW     <= X"0003B";
          lcdWState      <= writeCharUpperWait;
        when writeCharUpperWait =>
          writeNibbleW <= '0';
          cntSetW      <= '0';
          if cntFinish = '1' then
            lcdWState <= writeCharLower;
          else
            lcdWState <= writeCharUpperWait;
          end if;
        when writeCharLower =>
          writeNibbleW   <= '1';
          lcdRSNowW      <= '1';
          lcdDataNibbleW <= lcdWriteData(3 downto 0);
          cntSetW        <= '1';
          cntPresetW     <= X"00840";
          lcdWState      <= writeCharLowerWait;
        when writeCharLowerWait =>
          writeNibbleW <= '0';
          cntSetW      <= '0';
          if cntFinish = '1' then
            lcdWState <= writeCharCheckAddr;
          else
            lcdWState <= writeCharLowerWait;
          end if;

        when writeCharCheckAddr =>
          if std_logic_vector(writeCharPos) = "11101" then
            writeCharPos <= "00000";
          else
            writeCharPos <= writeCharPos + 1;
          end if;

          if std_logic_vector(writeCharPos) = "01110" then
            lcdWState <= writeCharSetLine2p1;
          elsif std_logic_vector(writeCharPos) = "11101" then
            lcdWState <= writeCharSetLine1p1;
          else
            lcdWState <= writeCharFinished;
          end if;
          
        when writeCharSetLine1p1 =>
          writeNibbleW   <= '1';
          lcdRSNowW      <= '0';
          lcdDataNibbleW <= X"8";
          cntSetW        <= '1';
          cntPresetW     <= X"0003B";
          lcdWState      <= writeCharSetLine1p1Wait;
        when writeCharSetLine1p1Wait =>
          writeNibbleW <= '0';
          cntSetW      <= '0';
          if cntFinish = '1' then
            lcdWState <= writeCharSetLine1p2;
          else
            lcdWState <= writeCharSetLine1p1Wait;
          end if;
        when writeCharSetLine1p2 =>
          writeNibbleW   <= '1';
          lcdRSNowW      <= '0';
          lcdDataNibbleW <= X"0";
          cntSetW        <= '1';
          cntPresetW     <= X"00840";
          lcdWState      <= writeCharSetLine1p2Wait;
        when writeCharSetLine1p2Wait =>
          writeNibbleW <= '0';
          cntSetW      <= '0';
          if cntFinish = '1' then
            lcdWState <= writeCharFinished;
          else
            lcdWState <= writeCharSetLine1p2Wait;
          end if;

          
        when writeCharSetLine2p1 =>
          writeNibbleW   <= '1';
          lcdRSNowW      <= '0';
          lcdDataNibbleW <= X"C";
          cntSetW        <= '1';
          cntPresetW     <= X"0003B";
          lcdWState      <= writeCharSetLine2p1Wait;
        when writeCharSetLine2p1Wait =>
          writeNibbleW <= '0';
          cntSetW      <= '0';
          if cntFinish = '1' then
            lcdWState <= writeCharSetLine2p2;
          else
            lcdWState <= writeCharSetLine2p1Wait;
          end if;
        when writeCharSetLine2p2 =>
          writeNibbleW   <= '1';
          lcdRSNowW      <= '0';
          lcdDataNibbleW <= X"0";
          cntSetW        <= '1';
          cntPresetW     <= X"00840";
          lcdWState      <= writeCharSetLine2p2Wait;
        when writeCharSetLine2p2Wait =>
          writeNibbleW <= '0';
          cntSetW      <= '0';
          if cntFinish = '1' then
            lcdWState <= writeCharFinished;
          else
            lcdWState <= writeCharSetLine2p2Wait;
          end if;

        when writeCharFinished =>
          lcdWriteFinish <= '1';
          lcdWState      <= waitForRequest;
          
        when others => null;
      end case;
      
    end if;
  end process lcdWriteVal;




  -- purpose: down-counter to be used by several processes, indicating when
  --          reaching 0
  -- type   : sequential
  -- inputs : clk, reset, cntSet, cntPreset
  -- outputs: cntFinish
  cntProcess : process (clk, reset)
  begin  -- process cntProcess
    if reset = '0' then                 -- asynchronous reset (active low)
      cntVal <= (others => '1');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if cntSet = '1' then
        cntVal <= unsigned(cntPreset);
      else
        if std_logic_vector(cntVal) = X"00000" then
          cntFinish <= '1';
        else
          cntFinish <= '0';
        end if;
        if std_logic_vector(cntVal) /= X"FFFFF" then
          cntVal <= cntVal - 1;
        end if;
      end if;
      
    end if;
  end process cntProcess;

  -- purpose: write out nibble to LCD
  -- type   : sequential
  -- inputs : clk, reset
  writeNibble : process (clk, reset)
  begin  -- process writeNibble
    if reset = '0' then                 -- asynchronous reset (active low)
      lcdRW      <= '1';
      lcdE       <= '0';
      lcdRS      <= '0';
      writeState <= waiting;
    elsif clk'event and clk = '1' then  -- rising clock edge
      case writeState is
        when waiting =>
          -- check if write request is available (writeNibble = '1'), otherwise
          -- remain in wait state
          if lcdWriteNibble = '1' then
            writeState <= write0;
          else
            writeState <= waiting;
          end if;
        when write0 =>
          -- apply data and control signals
          lcdRW      <= '0';
          lcdRS      <= lcdRSNow;
          lcdData    <= lcdDataNibble;
          writeState <= write1;
        when write1 =>
          -- wait one period to fulfil timing requirements
          writeState <= write2;
        when write2 =>
          -- set lcd enable to 1
          lcdE       <= '1';
          writeState <= writeWaitEnable;
        when writeWaitEnable =>
          -- then wait for 12 clock periods
          enableClksCnt <= enableClksCnt + 1;
          if std_logic_vector(enableClksCnt) = X"B" then
            writeState <= write3;
          else
            writeState <= writeWaitEnable;
          end if;
        when write3 =>
          -- lcd enable back to 0 and reset counter
          lcdE          <= '0';
          enableClksCnt <= X"0";
          writeState    <= write4;
        when write4 =>
          -- reset lcd read/write and go back to wait
          lcdRW      <= '1';
          writeState <= waiting;
        when others => null;
      end case;
    end if;
  end process writeNibble;

  -- output control data according to current state (counter and lcd write
  -- process are first controlled by init process, after that by write char process)
  lcdWriteNibble <= writeNibbleW when lcdIState = initFinished
                    else writeNibbleI;
  lcdRSNow <= lcdRSNowW when lcdIState = initFinished
              else lcdRSNowI;
  lcdDataNibble <= lcdDataNibbleW when lcdIState = initFinished
                   else lcdDataNibbleI;
  cntSet <= cntSetW when lcdIState = initFinished
            else cntSetI;
  cntPreset <= cntPresetW when lcdIState = initFinished
               else cntPresetI;


end behavior;











library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;


entity byteToDisplay is
  
  port (
    clk      : in  std_logic;
    reset    : in  std_logic;
    dispData : in  std_logic_vector(7 downto 0);
    dispReq  : in  std_logic;
    lcdData  : out std_logic_vector(3 downto 0);
    lcdRS    : out std_logic;
    lcdRW    : out std_logic;
    lcdE     : out std_logic);

end byteToDisplay;


architecture behavior of byteToDisplay is

  component LCDInterface
    port (
      clk            : in  std_logic;
      reset          : in  std_logic;
      lcdData        : out std_logic_vector(3 downto 0);
      lcdRS          : out std_logic;
      lcdRW          : out std_logic;
      lcdE           : out std_logic;
      lcdReqWrite    : in  std_logic;
      lcdWriteData   : in  std_logic_vector(7 downto 0);
      lcdWriteFinish : out std_logic);
  end component;

  type   outputDataStates is (waitForData, outputUpper, outputUpperWait, outputLower, outputLowerWait, outputSpace, outputSpaceWait);
  signal outputState : outputDataStates := waitForData;


  signal scancodeup, scancodelow : unsigned(7 downto 0);

  signal lcdReqWrite, lcdWriteFinish : std_logic;
  signal lcdWriteData                : std_logic_vector(7 downto 0);

  signal lcdReq, reqLast : std_logic := '0';
  signal dataLast        : std_logic_vector(7 downto 0);
  

begin  -- behavior

  LCDInterface_1 : LCDInterface
    port map (
      clk            => clk,
      reset          => reset,
      lcdData        => lcdData,
      lcdRS          => lcdRS,
      lcdRW          => lcdRW,
      lcdE           => lcdE,
      lcdReqWrite    => lcdReqWrite,
      lcdWriteData   => lcdWriteData,
      lcdWriteFinish => lcdWriteFinish);

  -- purpose: check if a rising edge of dispReq occured and if so, init output of data
  -- type   : sequential
  -- inputs : clk, reset, dispReq, dispData
  -- outputs: >
  checkTrigger : process (clk, reset)
  begin  -- process checkTrigger
    if reset = '0' then                 -- asynchronous reset (active low)
      lcdReq   <= '0';
      dataLast <= (others => '0');
      reqLast  <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if (dispReq = '1') and (dispReq /= reqLast) then
        lcdReq      <= '1';
        scancodeup  <= ("0000" & unsigned(dataLast(7 downto 4)));
        scancodelow <= ("0000" & unsigned(dataLast(3 downto 0)));
      else
        lcdReq <= '0';
      end if;
      dataLast <= dispData;
      reqLast  <= dispReq;
    end if;
  end process checkTrigger;

  -- purpose: if there is a new input scan code, output it to the LCD
  -- type   : sequential
  -- inputs : clk, reset, lcdReq, lcdWriteFinish
  -- outputs: lcdReqWrite, lcdWriteData
  outputData : process (clk, reset)
  begin  -- process outputData
    if reset = '0' then                 -- asynchronous reset (active low)
      lcdReqWrite <= '0';
      outputState <= waitForData;
    elsif clk'event and clk = '1' then  -- rising clock edge
      case outputState is
        when waitForData =>
          -- check if new data is available
          if lcdReq = '1' then
            -- if yes, buffer and start to output
            outputState <= outputUpper;
          else
            outputState <= waitForData;
          end if;
        when outputUpper =>
          -- match scancode to LCD coding table
          if scancodeup(3 downto 0) > conv_unsigned(9, 4) then
            lcdWriteData <= scancodeup + conv_unsigned(55, 8);
          else
            lcdWriteData <= scancodeup + conv_unsigned(48, 8);
          end if;
          lcdReqWrite <= '1';
          outputState <= outputUpperWait;
        when outputUpperWait =>
          lcdReqWrite <= '0';
          -- wait until the LCD interface is finished
          if lcdWriteFinish = '1' then
            outputState <= outputLower;
          else
            outputState <= outputUpperWait;
          end if;
        when outputLower =>
          -- match scancode to LCD coding table
          if scancodelow(3 downto 0) > conv_unsigned(9, 4) then
            lcdWriteData <= scancodelow + conv_unsigned(55, 8);
          else
            lcdWriteData <= scancodelow + conv_unsigned(48, 8);
          end if;
          lcdReqWrite <= '1';
          outputState <= outputLowerWait;
        when outputLowerWait =>
          -- wait until the LCD interface is finished
          lcdReqWrite <= '0';
          if lcdWriteFinish = '1' then
            outputState <= outputSpace;
          else
            outputState <= outputLowerWait;
          end if;
        when outputSpace =>
          -- output separating space
          lcdWriteData <= X"00";
          lcdReqWrite  <= '1';
          outputState  <= outputSpaceWait;
        when outputSpaceWait =>
          lcdReqWrite <= '0';
          -- wait until the LCD interface is finished
          if lcdWriteFinish = '1' then
            outputState <= waitForData;
          else
            outputState <= outputSpaceWait;
          end if;
        when others => null;
      end case;
      
    end if;
  end process outputData;

  
  

end behavior;

