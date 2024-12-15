library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity buttonTracker is
    PORT (
        clk          : IN  STD_LOGIC;
        keypress     : IN  STD_LOGIC_VECTOR(3 DOWNTO 0); -- 4 keypad inputs
        note_col_1   : IN  STD_LOGIC_VECTOR(599 DOWNTO 0); -- Falling notes from column 1
        note_col_2   : IN  STD_LOGIC_VECTOR(599 DOWNTO 0); -- Falling notes from column 2
        note_col_3   : IN  STD_LOGIC_VECTOR(599 DOWNTO 0); -- Falling notes from column 3
        note_col_4   : IN  STD_LOGIC_VECTOR(599 DOWNTO 0); -- Falling notes from column 4
        hit_signals : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- Signals to delete notes
        score        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) -- Score output
    );
end buttonTracker;

architecture Behavioral of buttonTracker is
    SIGNAL prev_keypress : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'); -- Tracks the previous state of keypress
    SIGNAL internal_score : STD_LOGIC_VECTOR(15 DOWNTO 0):= (OTHERS => '0');-- Score output
begin

    -- Process to handle keypress changes, scoring, and hit signals
  hit_tracker: process(clk)
    begin
        if rising_edge(clk) then
            -- Reset hit_signals
            hit_signals <= (OTHERS => '0');

            -- Check for keypress(0) and note_col_1 activity
            if keypress(0) = '1' and prev_keypress(0) = '0' then
                if note_col_1(580 downto 550) /= (OTHERS => '0') then
                    internal_score <= internal_score + 10; -- Increase score
                    hit_signals(0) <= '1'; -- Signal to delete notes in column 1
                elsif note_col_1(580 downto 550) = (OTHERS => '0') then
                    internal_score <= internal_score - 1;
                end if;
            end if;

            -- Check for keypress(1) and note_col_2 activity
            if keypress(1) = '1' and prev_keypress(1) = '0' then
                if note_col_2(580 downto 550) /= (OTHERS => '0') then
                    internal_score <= internal_score + 10; -- Increase score
                    hit_signals(1) <= '1'; -- Signal to delete notes in column 2
                elsif note_col_2(580 downto 550) = (OTHERS => '0') then
                    internal_score <= internal_score - 1;
                end if;
            end if;

            -- Check for keypress(2) and note_col_3 activity
            if keypress(2) = '1' and prev_keypress(2) = '0' then
                if note_col_3(580 downto 550) /= (OTHERS => '0') then
                    internal_score <= internal_score + 10; -- Increase score
                    hit_signals(2) <= '1'; -- Signal to delete notes in column 3
                elsif note_col_3(580 downto 550) = (OTHERS => '0') then
                    internal_score <= internal_score - 1;
                end if;
            end if;

            -- Check for keypress(3) and note_col_4 activity
            if keypress(3) = '1' and prev_keypress(3) = '0' then
                if note_col_4(580 downto 550) /= (OTHERS => '0') then
                    internal_score <= internal_score + 10; -- Increase score
                    hit_signals(3) <= '1'; -- Signal to delete notes in column 4
                elsif note_col_4(580 downto 550) = (OTHERS => '0') then
                    internal_score <= internal_score - 1;
                end if;
            end if;
        end if; 
        
        -- Update previous keypress state
        prev_keypress <= keypress;
        score <= internal_score;
    end process;

end Behavioral;
