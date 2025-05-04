library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.CHESS_TYPES.ALL;

entity moveChecker is
    port (CLK           : in    std_logic;
          overrideRules : in    std_logic; -- For Testing Purposes Only
          board         : in    boardType;
          sqSELi        : in    natural range 0 to 63;
          sqSELf        : in    natural range 0 to 63;
          wKpos         : in    natural range 0 to 63;
          bKpos         : in    natural range 0 to 63;
          turn          : in    std_logic;
          allCastle     : in    std_logic_vector(3 downto 0);
          moveable      : out   std_logic;
          turnKinCheck  : inout std_logic);
end moveChecker;

architecture Behavioral of moveChecker is
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
    
    component sqControlChecker is
        port (CLK       : in  std_logic;
              board     : in  boardType;
              player    : in  std_logic; -- Player Controlling Square '1' => White '0' => Black
              sq        : in  natural;
              inControl : out std_logic);
    end component;

signal ROWi, COLi, ROWf, COLf : natural range 0 to 7;
signal moveNUM      : natural range 0 to 7 := 0;
signal moveVector   : std_logic_vector(7 downto 0);
signal castle       : std_logic_vector(1 downto 0) := "00";

signal QcastinThreat : std_logic;
signal KcastinThreat : std_logic;

signal turn_n         : std_logic;
signal turnKpos       : natural range 0 to 63;

signal turnQcastPos : natural range 0 to 63;
signal turnKcastPos : natural range 0 to 63;

signal rookMoves    : std_logic;
signal bishopMoves  : std_logic;

begin
    turn_n <= NOT turn;
    
    -- Select Castling Side of the Board and the King Pos w/ turn
    -- To use half as many sqControlChecker modules
    with turn select
        turnKpos <= wKpos when '1',
                    bKpos when '0';
    with turn select
        turnQcastPos <= 3  when '0',
                        59 when '1';
    with turn select
        turnKcastPos <= 5  when '0',
                        61 when '1';
    
    Rmoves : rookMoveChecker
    port map (board, sqSELi, moveVector, turn,
              rookMoves);
    
    Bmoves : bishopMoveChecker
    port map (board, sqSELi, moveVector, turn,
              bishopMoves);
    
    turnKCheck      : sqControlChecker
    port map (CLK, board, turn_n, turnKpos,
              turnKinCheck);
    
    turnKsideCastle : sqControlChecker
    port map (CLK, board, turn_n, turnQcastPos,
              QcastinThreat);
    
    turnQsideCastle : sqControlChecker
    port map (CLK, board, turn_n, turnKcastPos,
              KcastinThreat);
    
    ROWi <= sqSELi / 8;
    COLi <= sqSELi mod 8;
    ROWf <= sqSELf / 8;
    COLf <= sqSELf mod 8;
    moveVector <= std_logic_vector(to_signed(COLf - COLi, 4))
                & std_logic_vector(to_signed(ROWf - ROWi, 4));
    -- moveVector is an 8 bit data in which the 7 downto 4 is the relative movement in x direction and other bits are relative movement in y direction
    
    -- Extract Castling Conditions
    -- Queen Side Castling
    castle(1) <= allCastle(1) AND (NOT turnKinCheck) AND (NOT QcastinThreat) when turn = '1' AND board(57) = 0 AND board(58) = 0 AND board(59) = 0 else 
                 allCastle(3) AND (NOT turnKinCheck) AND (NOT QcastinThreat) when turn = '0' AND board(1)  = 0 AND board(2)  = 0 AND board(3)  = 0 else '0';
    -- King Side Castling
    castle(0) <= allCastle(0) AND (NOT turnKinCheck) AND (NOT KcastinThreat) when turn = '1' AND board(61) = 0 AND board(62) = 0 else 
                 allCastle(2) AND (NOT turnKinCheck) AND (NOT KcastinThreat) when turn = '0' AND board(5)  = 0 AND board(6)  = 0 else '0';
    
    -- Main Move Rules Decider
    process(sqSELi, sqSELf, turn)
    begin
        moveable <= OverrideRules;
        
        -- Initial Pos Empty
        if board(sqSELi) = 0 then
            moveable <= '0';
        
        -- Same sq is selected
        elsif sqSELi = sqSELf then
            moveable <= '0';
        
        -- Selected Piece Not Player's
        elsif turn = '1' AND board(sqSELi) < 0 then                             
            moveable <= OverrideRules;
        elsif turn = '0' AND board(sqSELi) > 0 then
            moveable <= OverrideRules;
        
        -- Move done to own piece
        elsif turn = '1' AND board(sqSELf) > 0 then                             
            moveable <= '0';
        elsif turn = '0' AND board(sqSELf) < 0 then
            moveable <= '0';
            
        -- White Pawn Moves
        elsif board(sqSELi) = 1 then
            -- Starting White Pawn Double Move                       
            if moveVector = "00001110" then
                if ROWi = 6 then                                                
                    if board(sqSELf) = 0 AND board(sqSELi - 8) = 0 then
                        moveable <= '1';
                    end if;
                end if;
            
            -- Normal White Pawn Move
            elsif moveVector = "00001111" then
                if board(sqSELf) = 0 then
                    moveable <= '1';
                end if;
            
            -- Taking White Pawn Move
            elsif moveVector = "00011111" OR moveVector = "11111111" then
                if board(sqSELf) < 0 then
                    moveable <= '1';
                end if;
            end if;
        
        -- Black Pawn Moves    
        elsif board(sqSELi) = -1 then
            -- Starting Black Pawn Double Move                    
            if moveVector = "00000010" then
                if ROWi = 1 then                                                
                    if board(sqSELf) = 0 AND board(sqSELf - 8) = 0 then
                        moveable <= '1';
                    end if;
                end if;
                
            -- Normal Black Pawn Move
            elsif moveVector = "00000001" then                                     
                if board(sqSELf) = 0 then
                    moveable <= '1';
                end if;
            
            -- Taking Black Pawn Move
            elsif moveVector = "00010001" OR moveVector = "11110001" then
                if board(sqSELf) > 0 then
                    moveable <= '1';
                end if;
            end if; -- En Passant Not Implemented
        
        -- Rook Moves
        elsif board(sqSELi) = 2 OR board(sqSELi) = -2 then
            moveable <= rookMoves OR OverrideRules;
            
        -- Knight Moves
        elsif board(sqSELi) = 3 OR board(sqSELi) = -3 then
            case moveVector is
                when "00010010" => moveable <= '1';
                when "00011110" => moveable <= '1';
                when "11110010" => moveable <= '1';
                when "11111110" => moveable <= '1';
                when "00100001" => moveable <= '1';
                when "00101111" => moveable <= '1';
                when "11100001" => moveable <= '1';
                when "11101111" => moveable <= '1';
                when others => moveable <= OverrideRules;
           end case;
        
        -- Bishop Moves
        elsif board(sqSELi) = 4 OR board(sqSELi) = -4 then
            moveable <= bishopMoves OR OverrideRules;
        
        -- Queen Moves
        elsif board(sqSELi) = 5 OR board(sqSELi) = -5 then
            moveable <= rookMoves OR bishopMoves OR OverrideRules;
        
        -- King Moves
        elsif board(sqSELi) = 6 OR board(sqSELi) = -6 then
            case moveVector is
                when "00000001" => moveable <= '1';
                when "00001111" => moveable <= '1';
                when "00010000" => moveable <= '1';
                when "00010001" => moveable <= '1';
                when "00011111" => moveable <= '1';
                when "11110000" => moveable <= '1';
                when "11110001" => moveable <= '1';
                when "11111111" => moveable <= '1';
                when "00100000" => moveable <= castle(0) OR OverrideRules; -- King Side Castling
                when "11100000" => moveable <= castle(1) OR OverrideRules; -- Queen Side Castling
                when others => moveable <= OverrideRules;
            end case;
        end if;
    end process;
    
end Behavioral;
