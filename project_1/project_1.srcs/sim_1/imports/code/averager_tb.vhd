library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity averager_tb is
--  Port ( );
end averager_tb;

architecture Behavioral of averager_tb is
component averager is
    Port (  clk     : in std_logic;
            rst     : in std_logic;
            average : out STD_LOGIC_VECTOR (7 downto 0));
end component averager;

signal clk_tb, rst_tb : std_logic;
signal average_tb : std_logic_vector(7 downto 0);


begin

uut : averager port map( clk => clk_tb,
                         rst => rst_tb,
                         average => average_tb);
process begin
clk_tb <= '1';
wait for 10ns;
clk_tb <= '0';
wait for 10ns;
end process;

process begin
rst_tb <= '1';
wait for 200ns;
rst_tb <= '0';
wait;
end process;

end Behavioral;
