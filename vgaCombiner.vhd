LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY colorCombiner IS
	PORT (
		clk : IN STD_LOGIC;
		red_inputs   : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Supports up to 8 columns
		green_inputs : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		blue_inputs  : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		red_out      : OUT STD_LOGIC;
		green_out    : OUT STD_LOGIC;
		blue_out     : OUT STD_LOGIC
	);
END colorCombiner;
        
ARCHITECTURE Behavioral OF colorCombiner IS
BEGIN
	PROCESS(clk)
	BEGIN
	IF rising_edge(clk) THEN
        -- Default background color is white
        red_out   <= '1';
        green_out <= '1';
        blue_out  <= '1';

        -- Check for any active color stream
        IF red_inputs /= "1111" OR green_inputs /= "1111" OR blue_inputs /= "1111" THEN
            -- Combine colors based on the first active stream
            FOR i IN 0 TO 3 LOOP
                IF red_inputs(i) = '0' OR green_inputs(i) = '0' OR blue_inputs(i) = '0' THEN
                    red_out   <= red_inputs(i);
                    green_out <= green_inputs(i);
                    blue_out  <= blue_inputs(i);
                    EXIT;
                END IF;
            END LOOP;
        END IF;   
	END IF;
	END PROCESS;
END Behavioral;