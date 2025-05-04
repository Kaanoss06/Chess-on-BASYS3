library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.CHESS_TYPES.ALL;

entity sqControlChecker is
    port (CLK       : in  std_logic;
          board     : in  boardType;
          player    : in  std_logic; -- Player Controlling Square '1' => White '0' => Black
          sq        : in  natural range 0 to 63;
          inControl : out std_logic);
end sqControlChecker;

architecture Behavioral of sqControlChecker is
    component threatChecker is
        port (board    : in  boardType;
              sqSELi   : in  natural range 0 to 63;
              sqSELf   : in  natural range 0 to 63;
              turn     : in  std_logic;
              inThreat : out std_logic);
    end component;

signal sq_i        : natural range 0 to 63;
signal i           : natural range 0 to 65 := 0;
signal control_i   : std_logic;
signal anyControls : std_logic;

begin
    THREAT : threatChecker
    port map (board, sq_i, sq, player,
              control_i);
    
    process(CLK)
    begin
        if rising_edge(CLK) then
            if i = 65 then
                i <= 0;
            else
                i <= i + 1;
            end if;
            
            if i = 65 then
                anyControls <= '0';
            elsif i = 64 then
                inControl <= anyControls;
            else
                sq_i <= i;
                if control_i = '1' then
                    anyControls <= control_i;
                end if;
            end if;
        end if;
    end process;
    
end Behavioral;
