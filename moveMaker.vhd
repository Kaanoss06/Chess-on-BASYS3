library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.CHESS_TYPES.ALL;

entity moveMaker is
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
end moveMaker;

architecture switch_sq of moveMaker is
    component moveChecker is
        port (CLK           : in  std_logic;
              overrideRules : in  std_logic; 
              board         : in  boardType;
              sqSELi        : in  natural range 0 to 63;
              sqSELf        : in  natural range 0 to 63;
              wKpos         : in  natural range 0 to 63;
              bKpos         : in  natural range 0 to 63;
              turn          : in  std_logic;
              allCastle     : in  std_logic_vector(3 downto 0);
              moveable      : out std_logic;
              turnKinCheck  : out std_logic);
    end component;

signal sBoard : boardType := (
 2, 3, 4, 6, 5, 4, 3, 2,
 1, 1, 1, 1, 1, 1, 1, 1,
 0, 0, 0, 0, 0, 0, 0, 0,
 0, 0, 0, 0, 0, 0, 0, 0,
 0, 0, 0, 0, 0, 0, 0, 0,
 0, 0, 0, 0, 0, 0, 0, 0,
-1,-1,-1,-1,-1,-1,-1,-1,
-2,-3,-4,-6,-5,-4,-3,-2);

signal wKpos_i : natural range 0 to 63 := 60;
signal bKpos_i : natural range 0 to 63 := 4;

signal selPiece   : integer range -6 to 6;
signal turn_l     : std_logic := '1'; -- '1' means White's Turn
signal moveable   : std_logic;
signal allCastle  : std_logic_vector(3 downto 0) := "1111";
signal moveVector : std_logic_vector(7 downto 0);

signal ROWi, ROWf, COLi, COLf : natural range 0 to 7;

begin
    CHECK : moveChecker
    port map (CLK, SW(6), sBoard, sqSELi, sqSELf, wKpos_i, bKpos_i, turn_l, allCastle,
              moveable, turnKinCheck);
    
    process(LMRclk)
    begin
        selPiece <= sBoard(sqSELi);
        
        if rising_edge(LMRclk(1)) AND moveable = '1' then
            turn_l <= NOT turn_l;
            sBoard(sqSELi) <= 0;
            
            -- Set White Pawn on top of the board to Queen
            if sqSELf < 7 AND sBoard(sqSELi) = 1 then
                case SW(1 downto 0) is
                    when "00" => sBoard(sqSELf) <= 5;
                    when "01" => sBoard(sqSELf) <= 3;
                    when "10" => sBoard(sqSELf) <= 4;
                    when "11" => sBoard(sqSELf) <= 2;
                end case;
            -- Set Black Pawn on top of the board to Queen
            elsif 55 < sqSELf AND sBoard(sqSELi) = -1 then
                case SW(1 downto 0) is
                    when "00" => sBoard(sqSELf) <= -5;
                    when "01" => sBoard(sqSELf) <= -3;
                    when "10" => sBoard(sqSELf) <= -4;
                    when "11" => sBoard(sqSELf) <= -2;
                end case;
            else
                sBoard(sqSELf) <= selPiece;
            end if;
            
            -- Black Queen Side Rook Moved or Taken
            if sqSELi = 0 OR sqSElf = 0 then
                allCastle(3) <= '0';
            
            -- Black King Side Rook Moved or Taken       
            elsif sqSELi = 7 OR sqSELf = 7 then
                allCastle(2) <= '0';
                
            -- Black King Moved           
            elsif sqSELi = 4 then
                allCastle(3 downto 2) <= "00";
            
            -- White Queen Side Rook Moved or Taken
            elsif sqSELi = 56 OR sqSELf = 56 then
                allCastle(1) <= '0';
            
            -- White King Side Rook Moved or Taken
            elsif sqSELi = 63 OR sqSELf = 63 then
                allCastle(0) <= '0'; 
            
            -- White King Moved           
            elsif sqSELi = 60 then
                allCastle(1 downto 0) <= "00";  
            end if;
            
            -- Castle Move Rook Mover
            if selPiece = 6 OR selPiece = -6 then
                if sqSELf - sqSELi = 2 then
                    sBoard(sqSELf + 1) <= 0;
                    case turn_l is
                        when '0' => sBoard(sqSELf - 1) <= -2;
                        when '1' => sBoard(sqSELf - 1) <= 2;
                    end case;
                elsif sqSELf - sqSELi = -2 then
                    sBoard(sqSELf - 2) <= 0;
                    case turn_l is
                        when '0' => sBoard(sqSELf + 1) <= -2;
                        when '1' => sBoard(sqSELf + 1) <= 2;
                    end case;
                end if;
            end if;
            
            -- King Positions Tracker
            if selPiece = 6 then
                wKpos_i <= sqSElf;
            elsif selPiece = -6 then
                bKpos_i <= sqSELf;
            end if;
            
        end if;
    end process;
    
    board <= sBoard;
    wKpos <= wKpos_i;
    bKpos <= bKpos_i;
    turn  <= turn_l;
    
    LED(5)  <= moveable;
    LED(6)  <= SW(6);
    LED(1 downto 0) <= SW(1 downto 0);
    LED(3)  <= turn_l;
end switch_sq;
