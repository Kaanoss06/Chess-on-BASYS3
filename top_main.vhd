----------------------------------------------------------------------
-- Chess Run on BASYS3 FPGA Board -------------------- By Kaan UNCU --
----------------------------------------------------------------------
-- HOW TO PLAY:                                                     --
--    Connect VGA Port to a Monitor, Connect UBS-A port to a mouse  --
--    Select piece square by pressing LEFT CLICK on desired square  --
-- The selected square will turn yellow                             --
--    Select where to move by pressing LEFT CLICK                   --
-- The selected square will turn bright green                       --
--    After both colors can be seen press MIDDLE MOUSE BUTTON to    --
-- move the selected piece to the selected square                   --
--    To transform a pawn into a knight or bishop or rook before    --
-- the pawn is moved to the end of the board SW1 AND SW0 can be     --
-- used to select desired piece when SW(1 downto 0)                 --
--  "00" => Queen                                                   --
--  "01" => Knight                                                  --
--  "10" => Bishop                                                  --
--  "11" => Rook                                                    --
--    When King is in Check the square the king is on will turn red --
----------------------------------------------------------------------
-- NOT YET IMPLEMENTED FEATURES:                                    --
--    "En passant" move is not possible to do                       --
--    Game does not have an ending yet, game will end on king       --
-- capture. The player who captures opponent king will win the game --
----------------------------------------------------------------------
-- KNOWN BUGS:                                                      --
----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.CHESS_TYPES.ALL;

entity main is
    port (CLK100M  : in  std_logic;
          SW       : in  std_logic_vector(15 downto 0);
          LED      : out std_logic_vector(15 downto 0);
          Hsync    : out std_logic;
          Vsync    : out std_logic;
          RED      : out std_logic_vector(3 downto 0);
          GREEN    : out std_logic_vector(3 downto 0);
          BLUE     : out std_logic_vector(3 downto 0);
          ps2_clk  : inout std_logic;
          ps2_data : inout std_logic);
end main;

architecture pinConnector of main is
    component displayVGA is
        port (CLK25M       : in  std_logic;
              LMRclk       : in  std_logic_vector(2 downto 0);
              board        : in  boardType;
              xPos         : in  std_logic_vector(11 downto 0);
              yPos         : in  std_logic_vector(11 downto 0);
              wKpos        : in  natural range 0 to 63;
              bKpos        : in  natural range 0 to 63;
              turnKinCheck : in  std_logic;
              turn         : in  std_logic;
              gameOver     : in  std_logic;
              Hsync        : out std_logic;
              Vsync        : out std_logic;
              RED          : out std_logic_vector(3 downto 0);
              GREEN        : out std_logic_vector(3 downto 0);
              BLUE         : out std_logic_vector(3 downto 0);
              sqSELi       : out natural range 0 to 64;
              sqSELf       : out natural range 0 to 64);
    end component;
    
    component moveMaker is
        port (CLK          : in  std_logic;
              sqSELi       : in  natural;
              sqSELf       : in  natural;
              LMRclk       : in  std_logic_vector(2 downto 0); -- Left Middle Right Clicks
              SW           : in  std_logic_vector(15 downto 0);
              LED          : out std_logic_vector(15 downto 0);
              board        : out boardType;
              wKpos        : out natural range 0 to 63;
              bKpos        : out natural range 0 to 63;
              turnKinCheck : out std_logic;
              turn         : out std_logic);
    end component;
    
    component CLKdivider is
        port (CLK100M : in  std_logic;
              CLK25M  : out std_logic);
    end component;
    
    component mouseCtl is
        port(clk      : in    std_logic;
             xpos     : out   std_logic_vector(11 downto 0);
             ypos     : out   std_logic_vector(11 downto 0);
             left     : out   std_logic;
             middle   : out   std_logic;
             right    : out   std_logic;
             ps2_clk  : inout std_logic;
             ps2_data : inout std_logic);
    end component;
    
    component gameOverChecker is
        port (CLK       : in  std_logic;
              board     : in  boardType;
              gameOver  : out std_logic);
    end component;

signal board  : boardType;
signal CLK25M : std_logic;
signal LMRclk : std_logic_vector(2 downto 0);

signal xPos, yPos     : std_logic_vector(11 downto 0);
signal sqSELi, sqSELf : natural range 0 to 64 := 64;
signal wKpos, bKpos   : natural range 0 to 63;
signal turnKinCheck   : std_logic;
signal turn           : std_logic;
signal gameOver       : std_logic;

begin
    VGA : displayVGA
    port map (CLK25M, LMRclk, board, xPos, yPos, wKpos, bKpos, turnKinCheck, turn, gameOver,
              Hsync, Vsync, RED, GREEN, BLUE, sqSELi, sqSELf);
    
    MOV : moveMaker
    port map (CLK100M, sqSELi, sqSELf, LMRclk, SW,
              LED, board, wKpos, bKpos, turnKinCheck, turn);
    
    DIV : CLKdivider
    port map (CLK100M,
              CLK25M);
    
    MOUSE : mouseCtl
    port map (CLK100M,
              xPos, yPos, LMRclk(0), LMRclk(1), LMRclk(2),
              ps2_clk, ps2_data);
    
    ISGAMEON : gameOverChecker
    port map (CLK100M, board,
              gameOver);
end pinConnector;