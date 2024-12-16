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
        hit_sigB_1 : IN STD_LOGIC;
        hit_sigB_2 : IN STD_LOGIC;
        hit_sigB_3 : IN STD_LOGIC;
        hit_sigB_4 : IN STD_LOGIC;
        hit_signal_1 : OUT STD_LOGIC; -- Signal to delete notes
        hit_signal_2 : OUT STD_LOGIC; -- Signal to delete notes
        hit_signal_3 : OUT STD_LOGIC; -- Signal to delete notes
        hit_signal_4 : OUT STD_LOGIC; -- Signal to delete notes
        score        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) -- Score output
    );
end buttonTracker;

architecture Behavioral of buttonTracker is
    CONSTANT ZERO_VECTOR : STD_LOGIC_VECTOR(30 DOWNTO 0) := (OTHERS => '0'); 
    SIGNAL keypress0, keypress1, keypress2, keypress3 : STD_LOGIC;
    SIGNAL timeout1, timeout2, timeout3, timeout4 : STD_LOGIC;
    SIGNAL scoreset1, scoreset2, scoreset3, scoreset4 : STD_LOGIC;
    SIGNAL reset1, reset2, reset3, reset4 :STD_LOGIC;
    SIGNAL count1, count2, count3, count4 : INTEGER := 0;
    SIGNAL total_score : STD_LOGIC_VECTOR(15 downto 0);
    SIGNAL internal_score_1, internal_score_2, internal_score_3, internal_score_4 : STD_LOGIC_VECTOR(15 DOWNTO 0):= (OTHERS => '0');-- Score output
begin

    -- Process to handle keypress changes, scoring, and hit signals
  
  track_points: process(clk)
  begin
      if scoreset1 = '1' then
        total_score <= total_score + internal_score_1;
        reset1 <= '1';
      else
        reset1 <= '0';
      end if;
 
       if scoreset2 = '1' then
        total_score <= total_score + internal_score_2;
        reset2 <= '1';
      else
        reset2 <= '0';
      end if; 

      if scoreset3 = '1' then
        total_score <= total_score + internal_score_3;
        reset3 <= '1';
      else
        reset3 <= '0';
      end if;
      
      if scoreset4 = '1' then
        total_score <= total_score + internal_score_4;
        reset4 <= '1';
      else
        reset4 <= '0';
      end if;  
      
      score <= total_score;
  end process;
  
  hit_tracker1: process(clk)
    begin
        if rising_edge(clk) then
            -- Reset hit_signals
            if hit_sigB_1 = '1' then
                hit_signal_1 <= '0';
            end if;
            keypress0 <= keypress(0);
            
            -- Check for keypress(0) and note_col_1 activity
            if keypress0 = '1' then
                hit_signal_1 <= '1';
                if note_col_1(580 downto 550) /= zero_vector then
                        if reset1 = '0' then
                            internal_score_1 <= conv_std_logic_vector(10, 16); -- Increase score
                            scoreset1 <= '1';
                        else
                            internal_score_1 <= (others => '0');
                            scoreset1 <= '0'; -- 
                        end if;
                    hit_signal_1 <= '1'; -- Signal to delete notes in column 1
                elsif note_col_1(580 downto 550) = zero_vector then
                    if reset1 = '0' then
                            internal_score_1 <= not conv_std_logic_vector(1, 16) + 1; -- Increase score
                            scoreset1 <= '1';
                        else
                            internal_score_1 <= (others => '0');
                            scoreset1 <= '0'; -- 
                        end if;
                end if;
                timeout1 <= '1';
            end if;
            
            if timeout1 = '1' then
                if count1 <=500 then
                    count1 <= count1+1;
                else
                    count1 <= 0;
                    timeout1 <= '0';
                end if;
            end if;
                
        end if;
    END PROCESS;  

  hit_tracker2: process(clk)
    begin
        if rising_edge(clk) then
            -- Reset hit_signals
            if hit_sigB_2 = '1' then
                hit_signal_2 <= '0';
            end if;
            
            keypress1 <= keypress(1);
            
            -- Check for keypress(0) and note_col_1 activity
            if keypress1 = '1' and timeout2 = '0' then
                if note_col_2(580 downto 550) /= zero_vector then
                        if reset2 = '0' then
                            internal_score_2 <= conv_std_logic_vector(10, 16); -- Increase score
                            scoreset2 <= '1';
                        else
                            internal_score_2 <= (others => '0');
                            scoreset2 <= '0'; -- 
                        end if;
                    hit_signal_2 <= '1'; -- Signal to delete notes in column 1
                elsif note_col_2(580 downto 550) = zero_vector then
                    if reset2 = '0' then
                            internal_score_2 <= not conv_std_logic_vector(1, 16) + 1; -- Increase score
                            scoreset2 <= '1';
                        else
                            internal_score_2 <= (others => '0');
                            scoreset2 <= '0'; -- 
                        end if;
                end if;
                timeout2 <= '1';
            end if;
            
            if timeout2 = '1' then
                if count2 <=500 then
                    count2 <= count2+1;
                else
                    count2 <= 0;
                    timeout2 <= '0';
                end if;
            end if;
                
        end if;
    END PROCESS;
 
  hit_tracker3: process(clk)
    begin
        if rising_edge(clk) then
            -- Reset hit_signals
            if hit_sigB_3 = '1' then
                hit_signal_3 <= '0';
            end if;
            
            keypress2 <= keypress(2);
            
            -- Check for keypress(0) and note_col_1 activity
            if keypress2 = '1' and timeout3 = '0' then
                if note_col_3(580 downto 550) /= zero_vector then
                        if reset3 = '0' then
                            internal_score_3 <= conv_std_logic_vector(10, 16); -- Increase score
                            scoreset3 <= '1';
                        else
                            internal_score_3 <= (others => '0');
                            scoreset3 <= '0'; -- 
                        end if;
                    hit_signal_3 <= '1'; -- Signal to delete notes in column 1
                elsif note_col_3(580 downto 550) = zero_vector then
                    if reset3 = '0' then
                            internal_score_3 <= not conv_std_logic_vector(1, 16) + 1; -- Increase score
                            scoreset3 <= '1';
                        else
                            internal_score_3 <= (others => '0');
                            scoreset3 <= '0'; -- 
                        end if;
                end if;
                timeout3 <= '1';
            end if;
            
            if timeout3 = '1' then
                if count3 <=500 then
                    count3 <= count3+1;
                else
                    count3 <= 0;
                    timeout3 <= '0';
                end if;
            end if;
                
        end if;
    END PROCESS; 
 
   hit_tracker4: process(clk)
    begin
        if rising_edge(clk) then
            -- Reset hit_signals
            if hit_sigB_4 = '1' then
                hit_signal_4 <= '0';
            end if;
            
            keypress3 <= keypress(3);
            
            -- Check for keypress(0) and note_col_1 activity
            if keypress3 = '1' and timeout4 = '0' then
                if note_col_4(580 downto 550) /= zero_vector then
                        if reset4 = '0' then
                            internal_score_4 <= conv_std_logic_vector(10, 16); -- Increase score
                            scoreset4 <= '1';
                        else
                            internal_score_4 <= (others => '0');
                            scoreset4 <= '0'; -- 
                        end if;
                    hit_signal_4 <= '1'; -- Signal to delete notes in column 1
                elsif note_col_4(580 downto 550) = zero_vector then
                    if reset4 = '0' then
                            internal_score_4 <= not conv_std_logic_vector(1, 16) + 1; -- Increase score
                            scoreset4 <= '1';
                        else
                            internal_score_4 <= (others => '0');
                            scoreset4 <= '0'; -- 
                        end if;
                end if;
                timeout4 <= '1';
            end if;
            
            if timeout4 = '1' then
                if count4 <=500 then
                    count4 <= count4+1;
                else
                    count4 <= 0;
                    timeout4 <= '0';
                end if;
            end if;
                
        end if;
    END PROCESS;   
    
end Behavioral;
