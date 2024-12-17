library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity buttonTracker is
    PORT (
        clk          : IN  STD_LOGIC;
        reset        : IN  STD_LOGIC;
        keypress     : IN  STD_LOGIC; -- 4 keypad inputs
        note_col_1   : IN  STD_LOGIC_VECTOR(599 DOWNTO 0); -- Falling notes from column 1
        hit_sigB_1 : IN STD_LOGIC;
        hit_signal_1 : OUT STD_LOGIC; -- Signal to delete notes
        score        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- Score output
    );
end buttonTracker;

architecture Behavioral of buttonTracker is
    CONSTANT ZERO_VECTOR : STD_LOGIC_VECTOR(580 downto 530) := (OTHERS => '0'); 
    SIGNAL keypress0 : STD_LOGIC;
    SIGNAL timeout1 : STD_LOGIC;
    SIGNAL count1: INTEGER := 0;
    SIGNAL total_score : STD_LOGIC_VECTOR(31 downto 0) := conv_std_logic_vector(0,32);
begin
  
  hit_tracker1: process(clk)
    begin
        if rising_edge(clk) then
            -- Reset hit_signals
            
            if reset = '1' then
                total_score <= conv_std_logic_vector(0,32);
            end if;
            
            if hit_sigB_1 = '1' then
                hit_signal_1 <= '0';
            end if;
            
            keypress0 <= keypress;
            
            -- Check for keypress(0) and note_col_1 activity
            if keypress0 = '1' and timeout1 = '0' then
                if note_col_1(580 downto 530) /= zero_vector then
                    total_score <= total_score + conv_std_logic_vector(256, 32); -- Increase score
                end if;
                hit_signal_1 <= '1'; -- Signal to delete notes in column 1
                timeout1 <= '1';
            end if;
            
            if timeout1 = '1' then
                if count1 <= 10000000 then
                    count1 <= count1+1;
                else
                    count1 <= 0;
                    timeout1 <= '0';
                end if;
            end if; 
            
            score <= total_score;       
        end if; 
    END PROCESS;  
end Behavioral;
