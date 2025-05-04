library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.CHESS_TYPES.ALL;

entity rookMoveChecker is
    port (board      : in  boardType;
          sqSELi     : in  natural;
          moveVector : in  std_logic_vector(7 downto 0);
          turn       : in  std_logic;
          rookMoves  : out std_logic);
end rookMoveChecker;

architecture Behavioral of rookMoveChecker is

signal piecesAlong       : std_logic_vector(5 downto 0);
signal moveVect_n_pieces : std_logic_vector(13 downto 0);

begin
    process(sqSELi, moveVector, turn)
    begin
        piecesAlong <= "000000";
        
        if moveVector(7 downto 3) = "00000" then
            for i in 1 to 6 loop
                if i < to_integer(signed(moveVector(3 downto 0))) then
                    case board(sqSELi + (8 * i)) is
                        when 0 => piecesAlong(i - 1) <= '0';
                        when others => piecesAlong(i - 1) <= '1';
                    end case;
                end if;
            end loop;
            
        elsif moveVector(7 downto 3) = "00001" then
            for i in 1 to 6 loop
                if i < abs(signed(moveVector(3 downto 0))) then
                    case board(sqSELi - (8 * i)) is
                        when 0 => piecesAlong(i - 1) <= '0';
                        when others => piecesAlong(i - 1) <= '1';
                    end case;
                end if;
            end loop;
        
        elsif moveVector(3 downto 0) = "0000" AND moveVector(7) = '0' then
            for i in 1 to 6 loop
                if i < signed(moveVector(7 downto 4)) then
                    case board(sqSELi +  i) is
                        when 0 => piecesAlong(i - 1) <= '0';
                        when others => piecesAlong(i - 1) <= '1';
                    end case;
                end if;
            end loop;
        
        elsif moveVector(3 downto 0) = "0000" AND moveVector(7) = '1' then
            for i in 1 to 6 loop
                if i < abs(signed(moveVector(7 downto 4))) then
                    case board(sqSELi - i) is
                        when 0 => piecesAlong(i - 1) <= '0';
                        when others => piecesAlong(i - 1) <= '1';
                    end case;
                end if;
            end loop;
        end if;
    end process;
    
    moveVect_n_pieces <= moveVector & piecesAlong;
    
    with moveVect_n_pieces select
        rookMoves <= '1' when "00000001000000",
                     '1' when "00000010000000",
                     '1' when "00000011000000",
                     '1' when "00000100000000",
                     '1' when "00000101000000",
                     '1' when "00000110000000",
                     '1' when "00000111000000",
                     
                     '1' when "00001111000000",
                     '1' when "00001110000000",
                     '1' when "00001101000000",
                     '1' when "00001100000000",
                     '1' when "00001011000000",
                     '1' when "00001010000000",
                     '1' when "00001001000000",
                     
                     '1' when "00010000000000",
                     '1' when "00100000000000",
                     '1' when "00110000000000",
                     '1' when "01000000000000",
                     '1' when "01010000000000",
                     '1' when "01100000000000",
                     '1' when "01110000000000",
                     
                     '1' when "11110000000000",
                     '1' when "11100000000000",
                     '1' when "11010000000000",
                     '1' when "11000000000000",
                     '1' when "10110000000000",
                     '1' when "10100000000000",
                     '1' when "10010000000000",
                     
                     '0' when others;
    
end Behavioral;
