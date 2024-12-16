LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY keypad IS
	PORT (
		samp_ck : IN STD_LOGIC; -- clock to strobe columns
		col : OUT STD_LOGIC_VECTOR (4 DOWNTO 1); -- output column lines
		row : IN STD_LOGIC_VECTOR (4 DOWNTO 1); -- input row lines
		value : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- hex value of key depressed
		keypress_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- keypresses for notes
	hit : OUT STD_LOGIC); -- indicates when a key has been pressed
END keypad;

ARCHITECTURE Behavioral OF keypad IS
	SIGNAL CV1, CV2, CV3, CV4 : std_logic_vector (4 DOWNTO 1) := "1111"; -- column vector of each row
	SIGNAL keypress0, keypress1, keypress2, keypress3 : STD_LOGIC;
	--SIGNAL Pre_CV1, Pre_CV2, Pre_CV3, Pre_CV4 : std_logic_vector (4 DOWNTO 1) := "1111";
	SIGNAL curr_col : std_logic_vector (4 DOWNTO 1) := "1110"; -- current column code
BEGIN
	-- This process synchronously tests the state of the keypad buttons. On each edge of samp_ck,
	-- this module outputs a column code to the keypad in which one column line is held low while the
	-- other three column lines are held high. The row outputs of that column are then read
	-- into the corresponding column vector. The current column is then updated ready for the next
	-- clock edge. Remember that curr_col is not updated until the process suspends.
	strobe_proc : PROCESS
	BEGIN
		WAIT UNTIL rising_edge(samp_ck);
		CASE curr_col IS
			WHEN "1110" => 
				CV1 <= row;
				curr_col <= "1101";
			WHEN "1101" => 
				CV2 <= row;
				curr_col <= "1011";
			WHEN "1011" => 
				CV3 <= row;
				curr_col <= "0111";
			WHEN "0111" => 
				CV4 <= row;
				curr_col <= "1110";
			WHEN OTHERS => 
				curr_col <= "1110";
		END CASE;
		
		keypress_out(0) <= keypress0;
		keypress_out(1) <= keypress1;
		keypress_out(2) <= keypress2;
		keypress_out(3) <= keypress3;
		
	END PROCESS;
	-- This process runs whenever any of the column vectors change. Each vector is tested to see
	-- if there are any '0's in the vector. This would indicate that a button had been pushed in
	-- that column. If so, the value of the button is output and the hit signal is assereted. If
	-- not button is pushed, the hit signal is cleared
	
	
	
    blue_proc : PROCESS (CV1)
    BEGIN  
        -- Check for each button and set the corresponding keypress bit
        IF CV1(4) = '0' THEN -- Column 1, Row 4 (Button "0")
            keypress0 <= '1';
            --hit <= '1';   
        ELSE 
            keypress0 <= '0';
            --hit <= '0';
        END IF;
    END PROCESS;
    
    red_proc : PROCESS (CV2)
    BEGIN  
        IF CV2(4) = '0' THEN -- Column 2, Row 4 (Button "F")
            keypress1 <= '1';
           -- hit <= '1';
        ELSE 
            keypress1 <= '0';
           -- hit <= '0';
        END IF;
    END PROCESS;
    
    green_proc : PROCESS (CV3)
    BEGIN  
        -- Check for each button and set the corresponding keypress bit 
        IF CV3(4) = '0' THEN -- Column 3, Row 4 (Button "E")
            keypress2 <= '1';
         --   hit <= '1';
        ELSE 
            keypress2 <= '0';
          --  hit <= '0';
        END IF;
    END PROCESS;
    
    purple_proc : PROCESS (CV4)
    BEGIN  
        IF CV4(4) = '0' THEN -- Column 4, Row 4 (Button "D")
            keypress3 <= '1';
          --  hit <= '1';
        ELSE 
            keypress3 <= '0';
          --  hit <= '0';
        END IF;
    END PROCESS;
    
	col <= curr_col;
END Behavioral;