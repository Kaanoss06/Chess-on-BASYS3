library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.CHESS_TYPES.ALL;

entity threatChecker is
    port (board         : in  boardType;
          sqSELi        : in  natural range 0 to 63;
          sqSELf        : in  natural range 0 to 63;
          turn          : in  std_logic; 
          inThreat      : out std_logic);
end threatChecker;

architecture Behavioral of threatChecker is
    component rookMoveChecker is
        port (board      : in  boardType;
              sqSELi     : in  natural;
              moveVector : in  std_logic_vector(7 downto 0);
              turn       : in  std_logic;
              rookMoves  : out std_logic);
    end component;
    
    component bishopMoveChecker is
        port (board        : in  boardType;
              sqSELi       : in  natural;
              moveVector   : in  std_logic_vector(7 downto 0);
              turn         : in  std_logic;
              bishopMoves  : out std_logic);
    end component;

signal ROWi, COLi, ROWf, COLf : natural range 0 to 7;
signal moveNUM     : natural range 0 to 7 := 0;
signal moveVector  : std_logic_vector(7 downto 0);

signal rookMoves   : std_logic;
signal bishopMoves : std_logic;

begin
    Rmoves : rookMoveChecker
    port map (board, sqSELi, moveVector, turn,
              rookMoves);
    
    Bmoves : bishopMoveChecker
    port map (board, sqSELi, moveVector, turn,
              bishopMoves);
    
    ROWi <= sqSELi / 8;
    COLi <= sqSELi mod 8;
    ROWf <= sqSELf / 8;
    COLf <= sqSELf mod 8;
    moveVector <= std_logic_vector(to_signed(COLf - COLi, 4))
                & std_logic_vector(to_signed(ROWf - ROWi, 4));
    
    process(sqSELi, sqSELf, turn)
    begin
        inThreat <= '0';
        
        -- Initial Pos Empty
        if board(sqSELi) = 0 then                                               
            inThreat <= '0';
        
        -- Same sq is selected
        elsif sqSELi = sqSELf then                                              
            inThreat <= '0';
        
        -- Selected Piece Not Player's            
        elsif turn = '1' AND board(sqSELi) < 0 then                             
            inThreat <= '0';
        elsif turn = '0' AND board(sqSELi) > 0 then
            inThreat <= '0';
            
        -- White Pawn Moves    
        elsif board(sqSELi) = 1 then
            -- Taking White Pawn Move
            if moveVector = "00011111" OR moveVector = "11111111" then
                inThreat <= '1';
            end if;
        
        -- Black Pawn Moves
        elsif board(sqSELi) = -1 then
            if moveVector = "00010001" OR moveVector = "11110001" then
                inThreat <= '1';
            end if;
        
        -- Rook Moves
        elsif board(sqSELi) = 2 OR board(sqSELi) = -2 then
            inThreat <= rookMoves;
            
        -- Knight Moves
        elsif board(sqSELi) = 3 OR board(sqSELi) = -3 then
            case moveVector is
                when "00010010" => inThreat <= '1';
                when "00011110" => inThreat <= '1';
                when "11110010" => inThreat <= '1';
                when "11111110" => inThreat <= '1';
                when "00100001" => inThreat <= '1';
                when "00101111" => inThreat <= '1';
                when "11100001" => inThreat <= '1';
                when "11101111" => inThreat <= '1';
                when others => inThreat <= '0';
           end case;
        
        -- Bishop Moves
        elsif board(sqSELi) = 4 OR board(sqSELi) = -4 then
            inThreat <= bishopMoves;
        
        -- Queen Moves
        elsif board(sqSELi) = 5 OR board(sqSELi) = -5 then
            inThreat <= rookMoves OR bishopMoves;
        
        -- King Moves
        elsif board(sqSELi) = 6 OR board(sqSELi) = -6 then
            case moveVector is
                when "00000001" => inThreat <= '1';
                when "00001111" => inThreat <= '1';
                when "00010000" => inThreat <= '1';
                when "00010001" => inThreat <= '1';
                when "00011111" => inThreat <= '1';
                when "11110000" => inThreat <= '1';
                when "11110001" => inThreat <= '1';
                when "11111111" => inThreat <= '1';
                when others => inThreat <= '0';
            end case;
        end if;
    end process;
    
end Behavioral;
