library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity averager_50 is
    Port (  clk     : in std_logic;
            rst     : in std_logic;
            average : out STD_LOGIC_VECTOR (7 downto 0));
end averager_50;

architecture Behavioral of averager_50 is
component blk_mem_gen_0 IS
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END component blk_mem_gen_0;

type state_type is (id, co, av);
signal state : state_type;

signal ena : std_logic;
signal wea : std_logic_vector (0 downto 0);
signal addra : std_logic_vector(6 downto 0);
signal dina, douta : std_logic_vector(7 downto 0);
signal i_lt32, i_clr, sum_clr, a_clr, avg_clr, i_ld, sum_ld, a_ld, avg_ld : std_logic := '0';
signal index : integer := 0;
signal sum : integer := 0;
signal a : integer := 0;

begin
bram : blk_mem_gen_0 port map ( clka => clk,
                  ena => ena,
                  wea => wea,
                  addra => addra,
                  dina => dina,
                  douta => douta);
ena <= '1';
wea <= "0";
addra <= std_logic_vector(to_unsigned(25+index,addra'length));

process(clk)
begin
if rising_edge(clk) then
    if (a_clr = '1') then
        a <= 0;
    elsif (a_ld = '1') then
        a <= to_integer(unsigned(douta));
    end if;
end if;
end process;

process(clk)
begin
if rising_edge(clk) then
    if (sum_clr = '1') then
        sum <= 0;
    elsif (sum_ld = '1') then
        sum <= sum + a;
    end if;
end if;
end process;

process(clk)
begin
if rising_edge(clk) then
    if (avg_clr = '1') then
        average <= ( others => '0' );
    elsif (avg_ld = '1') then
        average <= std_logic_vector(to_unsigned(sum/50,average'length)); 
    end if;
end if;
end process;

process(clk)
begin
if rising_edge(clk) then
    if (i_clr = '1') then
        index <= 0;
    elsif (i_ld = '1') then
        index <= index+1;
    end if;
end if;
end process;

process(clk)
begin
if rising_edge(clk) then
    case state is
        when id =>
            i_clr <= '1';
            i_ld <= '0';
            sum_clr <= '1';
            sum_ld <= '0';
            a_clr <= '1';
            a_ld <= '0';
            avg_clr <= '1';
            i_lt32 <= '1';
        when co =>
            i_clr <= '0';
            i_ld <= '1';
            sum_clr <= '0';
            a_clr <= '0';
            a_ld <= '1';
            avg_clr <= '0';
            if index = 2 then
                sum_ld <= '1';
            end if;
            if index >= 52 then
                i_lt32 <= '0';
                i_ld <= '0';
                sum_ld <= '0';
                a_ld <= '0';
            end if;
    when av =>
            avg_ld <= '1';
            
    when others =>
    end case;
end if;
end process;
            
process(clk)
begin
if (rst = '1') then
    state <= id;
elsif rising_edge(clk) then 
    case state is
        when id =>
            state <= co;
        when co =>
            if i_lt32 = '1' then
                state <= state;
            else
                state <= av;
            end if;
        when av =>
            if (rst = '1') then
                state <= id;
            end if;
        when others =>
            state <= id;
    end case; 
end if;
end process;
end Behavioral;


