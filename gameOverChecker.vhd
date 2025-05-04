library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.CHESS_TYPES.ALL;

entity gameOverChecker is
    port (CLK       : in  std_logic;
          board     : in  boardType;
          gameOver  : out std_logic);
end gameOverChecker;

architecture Behavioral of gameOverChecker is

signal i : natural range 0 to 65 := 0;

signal bKpresent : std_logic;
signal wKpresent : std_logic;

begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            if i = 65 then
                i <= 0;
            else
                i <= i + 1;
            end if;
            
            if i = 65 then
                wKpresent <= '0';
                bKpresent <= '0';
            elsif i = 64 then
                gameOver <= NOT (wKpresent AND bKpresent);
            else
                if board(i) = 6 then
                    wKpresent <= '1';
                elsif board(i) = -6 then
                    bKpresent <= '1';
                end if;
            end if;
        end if;
    end process;
    
end Behavioral;
