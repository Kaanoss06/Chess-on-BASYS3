library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.CHESS_TYPES.ALL;

entity displayVGA is
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
          sqSELi       : inout natural range 0 to 64;
          sqSELf       : inout natural range 0 to 64);
end displayVGA;

architecture Behavioral of displayVGA is

signal H_num          : natural range 0 to 799;
signal V_num          : natural range 0 to 524;
signal VideoOn        : std_logic;
signal RGB            : std_logic_vector(11 downto 0) := (others => '0');
signal sqROW, sqCOL   : natural range 0 to 7;
signal sqNUM          : natural range 0 to 63;
signal inBoard        : std_logic;
signal clickNum       : natural range 0 to 2;
signal sqHpos, sqVpos : natural range 0 to 19;

begin
    -- VGA Pixel Processor
    process(CLK25M) 
    begin
        if rising_edge(CLK25M) then
            if H_num < 799 then
                H_num <= H_num + 1;
            else
                H_num <= 0;
                if V_num < 524 then
                    V_num <= V_num + 1;
                else
                    V_num <= 0;        
                end if;
            end if;
        end if;
    end process;
    
    -- Square Selection Process
    process(LMRclk) 
    begin
        if rising_edge(LMRclk(0)) then
            if clickNum = 0 then
                clickNum <= 1;
                sqSELi <= ((to_integer(unsigned(xPos)) - 224) / 60) 
                        + (8 * ((to_integer(unsigned(yPos)) - 35)/ 60));
            elsif clickNum = 1 then
                clickNum <= 2;
                sqSELf <= ((to_integer(unsigned(xPos)) - 224) / 60) 
                        + (8 * ((to_integer(unsigned(yPos)) - 35) / 60));
            else
                clickNum <= 0;
                sqSELi <= 64;
                sqSELf <= 64;
            end if;
        end if;
    end process;
    
    -- Sync Signals
    Hsync <= '0' when H_num < 96 else '1';
    Vsync <= '0' when V_num < 2  else '1';
    
    -- VGA Coloring process inside Board
    process(H_num, V_num)
    begin
        sqROW  <= (H_num - 224) / 60;
        sqCOL  <= (V_num - 35)  / 60;
        sqNUM  <= sqROW + (8 * sqCOL);
        sqHpos <= (H_num - 224 - (60 * sqROW)) / 3;
        sqVpos <= (V_num - 35  - (60 * sqCOL)) / 3;
        
        if gameOver = '0' then
            if sqNUM = sqSELi AND (NOT (sqSELi = 64)) AND ((sqHpos = 0) OR (sqHpos = 19) OR (sqVpos = 0) OR (sqVpos = 19)) then
                RGB <= "111111110000"; -- Yellow
            elsif sqNUM = sqSELf AND (NOT (sqSELf = 64)) AND ((sqHpos = 0) OR (sqHpos = 19) OR (sqVpos = 0) OR (sqVpos = 19)) then 
                RGB <= "000011110000"; -- Green
            elsif sqNUM = wKpos AND turnKinCheck = '1' AND turn = '1' AND ((sqHpos = 0) OR (sqHpos = 19) OR (sqVpos = 0) OR (sqVpos = 19)) then
                RGB <= "111100000000"; -- Red
            elsif sqNUM = bKpos AND turnKinCheck = '1' AND turn = '0' AND ((sqHpos = 0) OR (sqHpos = 19) OR (sqVpos = 0) OR (sqVpos = 19)) then
                RGB <= "111100000000"; -- Red
            elsif (sqROW + sqCOL) mod 2 = 0 then
                RGB <= "111111111111"; -- White
            else
                RGB <= "000000110000"; -- Dark Green
            end if;
            
            if board(sqNUM) = 1 then
                if pawnSymbol(sqHpos + (20 * sqVpos)) = 2 then
                    RGB <= "111111111111";
                elsif pawnSymbol(sqHpos + (20 * sqVpos)) = 1 then
                    RGB <= "000000000000";
                end if;
            elsif board(sqNUM) = -1 then
                if pawnSymbol(sqHpos + (20 * sqVpos)) = 2 then
                    RGB <= "010101010101";
                elsif pawnSymbol(sqHpos + (20 * sqVpos)) = 1 then
                    RGB <= "000000000000";
                end if;
            elsif board(sqNUM) = 2 then
                if rookSymbol(sqHpos + (20 * sqVpos)) = 2 then
                    RGB <= "111111111111";
                elsif rookSymbol(sqHpos + (20 * sqVpos)) = 1 then
                    RGB <= "000000000000";
                end if;
            elsif board(sqNUM) = -2 then
                if rookSymbol(sqHpos + (20 * sqVpos)) = 2 then
                    RGB <= "010101010101";
                elsif rookSymbol(sqHpos + (20 * sqVpos)) = 1 then
                    RGB <= "000000000000";
                end if;
            elsif board(sqNUM) = -5 then
                if queenSymbol(sqHpos + (20 * sqVpos)) = 2 then
                    RGB <= "010101010101";
                elsif queenSymbol(sqHpos + (20 * sqVpos)) = 1 then
                    RGB <= "000000000000";
                end if;
            elsif board(sqNUM) = 5 then
                if queenSymbol(sqHpos + (20 * sqVpos)) = 2 then
                    RGB <= "111111111111";
                elsif queenSymbol(sqHpos + (20 * sqVpos)) = 1 then
                    RGB <= "000000000000";
                end if;
            elsif board(sqNUM) = -3 then
                if knightSymbol(sqHpos + (20 * sqVpos)) = 2 then
                    RGB <= "010101010101";
                elsif knightSymbol(sqHpos + (20 * sqVpos)) = 1 then
                    RGB <= "000000000000";
                end if;
            elsif board(sqNUM) = 3 then
                if knightSymbol(sqHpos + (20 * sqVpos)) = 2 then
                    RGB <= "111111111111";
                elsif knightSymbol(sqHpos + (20 * sqVpos)) = 1 then
                    RGB <= "000000000000";
                end if;
            elsif board(sqNUM) = -4 then
                if bishopSymbol(sqHpos + (20 * sqVpos)) = 2 then
                    RGB <= "010101010101";
                elsif bishopSymbol(sqHpos + (20 * sqVpos)) = 1 then
                    RGB <= "000000000000";
                end if;
            elsif board(sqNUM) = 4 then
                if bishopSymbol(sqHpos + (20 * sqVpos)) = 2 then
                    RGB <= "111111111111";
                elsif bishopSymbol(sqHpos + (20 * sqVpos)) = 1 then
                    RGB <= "000000000000";
                end if;
            elsif board(sqNUM) = -6 then
                if kingSymbol(sqHpos + (20 * sqVpos)) = 2 then
                    RGB <= "010101010101";
                elsif kingSymbol(sqHpos + (20 * sqVpos)) = 1 then
                    RGB <= "000000000000";
                end if;
            elsif board(sqNUM) = 6 then
                if kingSymbol(sqHpos + (20 * sqVpos)) = 2 then
                    RGB <= "111111111111";
                elsif kingSymbol(sqHpos + (20 * sqVpos)) = 1 then
                    RGB <= "000000000000";
                end if;
            end if;
            
        else -- Game is Over
            RGB <= "111111111111";
            
            if sqNum = 2 then
                if letterG(sqHpos + (20 * sqVpos)) = 1 then
                    RGB <= "000000000000";
                elsif letterG(sqHpos + (20 * sqVpos)) = 2 then
                    RGB <= "000001100111";
                elsif letterG(sqHpos + (20 * sqVpos)) = 3 then
                    RGB <= "111100000000";
                end if;
            elsif sqNum = 3 then
                if letterA(sqHpos + (20 * sqVpos)) = 1 then
                    RGB <= "000000000000";
                elsif letterA(sqHpos + (20 * sqVpos)) = 2 then
                    RGB <= "000001100111";
                elsif letterA(sqHpos + (20 * sqVpos)) = 3 then
                    RGB <= "111100000000";
                end if;
            elsif sqNum = 4 then
                if letterM(sqHpos + (20 * sqVpos)) = 1 then
                    RGB <= "000000000000";
                elsif letterM(sqHpos + (20 * sqVpos)) = 2 then
                    RGB <= "000001100111";
                elsif letterM(sqHpos + (20 * sqVpos)) = 3 then
                    RGB <= "111100000000";
                end if;
            elsif sqNum = 5 then
                if letterE(sqHpos + (20 * sqVpos)) = 1 then
                    RGB <= "000000000000";
                elsif letterE(sqHpos + (20 * sqVpos)) = 2 then
                    RGB <= "000001100111";
                elsif letterE(sqHpos + (20 * sqVpos)) = 3 then
                    RGB <= "111100000000";
                end if;
            elsif sqNum = 10 then
                if letterO(sqHpos + (20 * sqVpos)) = 1 then
                    RGB <= "000000000000";
                elsif letterO(sqHpos + (20 * sqVpos)) = 2 then
                    RGB <= "000001100111";
                elsif letterO(sqHpos + (20 * sqVpos)) = 3 then
                    RGB <= "111100000000";
                end if;
            elsif sqNum = 11 then
                if letterV(sqHpos + (20 * sqVpos)) = 1 then
                    RGB <= "000000000000";
                elsif letterV(sqHpos + (20 * sqVpos)) = 2 then
                    RGB <= "000001100111";
                elsif letterV(sqHpos + (20 * sqVpos)) = 3 then
                    RGB <= "111100000000";
                end if;
            elsif sqNum = 12 then
                if letterE(sqHpos + (20 * sqVpos)) = 1 then
                    RGB <= "000000000000";
                elsif letterE(sqHpos + (20 * sqVpos)) = 2 then
                    RGB <= "000001100111";
                elsif letterE(sqHpos + (20 * sqVpos)) = 3 then
                    RGB <= "111100000000";
                end if;
            elsif sqNum = 13 then
                if letterR(sqHpos + (20 * sqVpos)) = 1 then
                    RGB <= "000000000000";
                elsif letterR(sqHpos + (20 * sqVpos)) = 2 then
                    RGB <= "000001100111";
                elsif letterR(sqHpos + (20 * sqVpos)) = 3 then
                    RGB <= "111100000000";
                end if;
            elsif sqNum = 26 then
                if turn = '0' then
                    if letterW(sqHpos + (20 * sqVpos)) = 1 then
                        RGB <= "000000000000";
                    elsif letterW(sqHpos + (20 * sqVpos)) = 2 then
                        RGB <= "000001100111";
                    elsif letterW(sqHpos + (20 * sqVpos)) = 3 then
                        RGB <= "111100000000";
                    end if;
                else
                    if letterB(sqHpos + (20 * sqVpos)) = 1 then
                        RGB <= "000000000000";
                    elsif letterB(sqHpos + (20 * sqVpos)) = 2 then
                        RGB <= "000001100111";
                    elsif letterB(sqHpos + (20 * sqVpos)) = 3 then
                        RGB <= "111100000000";
                    end if;
                end if;
            elsif sqNum = 27 then
                if turn = '0' then
                    if letterH(sqHpos + (20 * sqVpos)) = 1 then
                        RGB <= "000000000000";
                    elsif letterH(sqHpos + (20 * sqVpos)) = 2 then
                        RGB <= "000001100111";
                    elsif letterH(sqHpos + (20 * sqVpos)) = 3 then
                        RGB <= "111100000000";
                    end if;
                else
                    if letterL(sqHpos + (20 * sqVpos)) = 1 then
                        RGB <= "000000000000";
                    elsif letterL(sqHpos + (20 * sqVpos)) = 2 then
                        RGB <= "000001100111";
                    elsif letterL(sqHpos + (20 * sqVpos)) = 3 then
                        RGB <= "111100000000";
                    end if;
                end if;
            elsif sqNum = 28 then
                if turn = '0' then
                    if letterI(sqHpos + (20 * sqVpos)) = 1 then
                        RGB <= "000000000000";
                    elsif letterI(sqHpos + (20 * sqVpos)) = 2 then
                        RGB <= "000001100111";
                    elsif letterI(sqHpos + (20 * sqVpos)) = 3 then
                        RGB <= "111100000000";
                    end if;
                else
                    if letterA(sqHpos + (20 * sqVpos)) = 1 then
                        RGB <= "000000000000";
                    elsif letterA(sqHpos + (20 * sqVpos)) = 2 then
                        RGB <= "000001100111";
                    elsif letterA(sqHpos + (20 * sqVpos)) = 3 then
                        RGB <= "111100000000";
                    end if;
                end if;
            elsif sqNum = 29 then
                if turn = '0' then
                    if letterT(sqHpos + (20 * sqVpos)) = 1 then
                        RGB <= "000000000000";
                    elsif letterT(sqHpos + (20 * sqVpos)) = 2 then
                        RGB <= "000001100111";
                    elsif letterT(sqHpos + (20 * sqVpos)) = 3 then
                        RGB <= "111100000000";
                    end if;
                else
                    if letterC(sqHpos + (20 * sqVpos)) = 1 then
                        RGB <= "000000000000";
                    elsif letterC(sqHpos + (20 * sqVpos)) = 2 then
                        RGB <= "000001100111";
                    elsif letterC(sqHpos + (20 * sqVpos)) = 3 then
                        RGB <= "111100000000";
                    end if;
                end if;
            elsif sqNum = 30 then
                if turn = '0' then
                    if letterE(sqHpos + (20 * sqVpos)) = 1 then
                        RGB <= "000000000000";
                    elsif letterE(sqHpos + (20 * sqVpos)) = 2 then
                        RGB <= "000001100111";
                    elsif letterE(sqHpos + (20 * sqVpos)) = 3 then
                        RGB <= "111100000000";
                    end if;
                else
                    if letterK(sqHpos + (20 * sqVpos)) = 1 then
                        RGB <= "000000000000";
                    elsif letterK(sqHpos + (20 * sqVpos)) = 2 then
                        RGB <= "000001100111";
                    elsif letterK(sqHpos + (20 * sqVpos)) = 3 then
                        RGB <= "111100000000";
                    end if;
                end if;
            elsif sqNum = 34 then
                if letterW(sqHpos + (20 * sqVpos)) = 1 then
                    RGB <= "000000000000";
                elsif letterW(sqHpos + (20 * sqVpos)) = 2 then
                    RGB <= "000001100111";
                elsif letterW(sqHpos + (20 * sqVpos)) = 3 then
                    RGB <= "111100000000";
                end if;
            elsif sqNum = 35 then
                if letterI(sqHpos + (20 * sqVpos)) = 1 then
                    RGB <= "000000000000";
                elsif letterI(sqHpos + (20 * sqVpos)) = 2 then
                    RGB <= "000001100111";
                elsif letterI(sqHpos + (20 * sqVpos)) = 3 then
                    RGB <= "111100000000";
                end if;
            elsif sqNum = 36 then
                if letterN(sqHpos + (20 * sqVpos)) = 1 then
                    RGB <= "000000000000";
                elsif letterN(sqHpos + (20 * sqVpos)) = 2 then
                    RGB <= "000001100111";
                elsif letterN(sqHpos + (20 * sqVpos)) = 3 then
                    RGB <= "111100000000";
                end if;
            elsif sqNum = 37 then
                if letterS(sqHpos + (20 * sqVpos)) = 1 then
                    RGB <= "000000000000";
                elsif letterS(sqHpos + (20 * sqVpos)) = 2 then
                    RGB <= "000001100111";
                elsif letterS(sqHpos + (20 * sqVpos)) = 3 then
                    RGB <= "111100000000";
                end if;
            end if;
        end if;
    end process;
    
    VideoOn <= '1' when H_num >= 144 AND H_num < 784 AND V_num >= 35 AND V_num < 515 else '0';
    inBoard <= '1' when H_num >= 224 AND H_num < 704 AND V_num >= 35 AND V_num < 515 else '0';
    
    process(VideoOn)
    begin
        if VideoOn = '1' then
            -- Mouse Positions Display
            if H_num = to_integer(unsigned(xPos)) OR V_num = to_integer(unsigned(yPos)) then
                RED   <= "1111";
                GREEN <= "0000";
                BLUE  <= "0000";
            elsif inBoard = '1' then
                RED   <= RGB(11 downto 8);
                GREEN <= RGB(7 downto 4);
                BLUE  <= RGB(3 downto 0);
            -- Board Border
            elsif H_num = 221 OR H_num = 706 OR H_num = 222 OR H_num = 223 OR H_num = 704 OR H_num = 705 then
                RED   <= "0000";
                GREEN <= "0000";
                BLUE  <= "0000";
            else
                RED   <= turn & turn & turn & turn;
                GREEN <= turn & turn & turn & turn;
                BLUE  <= turn & turn & turn & turn;
            end if;
        else
            RED   <= "0000";
            GREEN <= "0000";
            BLUE  <= "0000";
        end if;
    end process;
    
end Behavioral;
