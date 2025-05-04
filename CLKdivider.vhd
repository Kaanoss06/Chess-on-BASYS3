library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CLKdivider is
    port (CLK100M : in  std_logic;
          CLK25M  : out std_logic);
end CLKdivider;

architecture tFF_x_2 of CLKdivider is

signal CLK50M_t  : std_logic := '0';
signal CLK25M_t : std_logic := '0';

begin
    process(CLK100M)
    begin
        if rising_edge(CLK100M) then
            CLK50M_t <= NOT CLK50M_t;
            if CLK50M_t = '1' then
                CLK25M_t <= NOT CLK25M_t;
            end if;
        end if;
    end process;
    
    CLK25M <= CLK25M_t;   
end tFF_x_2;
