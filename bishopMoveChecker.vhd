library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.CHESS_TYPES.ALL;

entity bishopMoveChecker is
    port (board        : in  boardType;
          sqSELi       : in  natural;
          moveVector   : in  std_logic_vector(7 downto 0);
          turn         : in  std_logic;
          bishopMoves  : out std_logic);
end bishopMoveChecker;

architecture Behavioral of bishopMoveChecker is

signal piecesAlong       : std_logic_vector(5 downto 0);
signal moveVect_n_pieces : std_logic_vector(13 downto 0);

begin
    process(sqSELi, moveVector, turn)
    begin
        piecesAlong <= "000000";
        
        if moveVector(7 downto 4) = moveVector(3 downto 0) AND moveVector(7) = '0' then
            for i in 1 to 6 loop
                if i < signed(moveVector(3 downto 0)) then
                    case board(sqSELi + (9 * i)) is
                        when 0 => piecesAlong(i - 1) <= '0';
                        when others => piecesAlong(i - 1) <= '1';
                    end case;
                end if;
            end loop;
            
        elsif moveVector(7 downto 4) = moveVector(3 downto 0) AND moveVector(7) = '1' then
            for i in 1 to 6 loop
                if i < abs(signed(moveVector(3 downto 0))) then
                    case board(sqSELi - (9 * i)) is
                        when 0 => piecesAlong(i - 1) <= '0';
                        when others => piecesAlong(i - 1) <= '1';
                    end case;
                end if;
            end loop;
        
        elsif signed(moveVector(7 downto 4)) + signed(moveVector(3 downto 0)) = 0 AND moveVector(7) = '0' then
            for i in 1 to 6 loop
                if i < signed(moveVector(7 downto 4)) then
                    case board(sqSELi - (7 * i)) is
                        when 0 => piecesAlong(i - 1) <= '0';
                        when others => piecesAlong(i - 1) <= '1';
                    end case;
                end if;
            end loop;
        
        elsif signed(moveVector(7 downto 4)) + signed(moveVector(3 downto 0)) = 0 AND moveVector(7) = '1' then
            for i in 1 to 6 loop
                if i < signed(moveVector(3 downto 0)) then
                    case board(sqSELi + (7 * i)) is
                        when 0 => piecesAlong(i - 1) <= '0';
                        when others => piecesAlong(i - 1) <= '1';
                    end case;
                end if;
            end loop;
        end if;
    end process;
    
    moveVect_n_pieces <= moveVector & piecesAlong;
    
    with moveVect_n_pieces select
        bishopMoves <= '1' when "00010001000000",
                       '1' when "00100010000000",
                       '1' when "00110011000000",
                       '1' when "01000100000000",
                       '1' when "01010101000000",
                       '1' when "01100110000000",
                       '1' when "01110111000000",
                     
                       '1' when "11111111000000",
                       '1' when "11101110000000",
                       '1' when "11011101000000",
                       '1' when "11001100000000",
                       '1' when "10111011000000",
                       '1' when "10101010000000",
                       '1' when "10011001000000",
                     
                       '1' when "00011111000000",
                       '1' when "00101110000000",
                       '1' when "00111101000000",
                       '1' when "01001100000000",
                       '1' when "01011011000000",
                       '1' when "01101010000000",
                       '1' when "01111001000000",
                     
                       '1' when "11110001000000",
                       '1' when "11100010000000",
                       '1' when "11010011000000",
                       '1' when "11000100000000",
                       '1' when "10110101000000",
                       '1' when "10100110000000",
                       '1' when "10010111000000",
                     
                       '0' when others;
    
end Behavioral;
