LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY noteColumn IS
	PORT (
	    clk       : IN STD_LOGIC;
		v_sync    : IN STD_LOGIC;
		pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		horiz     : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		note_input: IN STD_LOGIC;
		hit_signals_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		keypress     : IN STD_LOGIC;
		note_col_out  : OUT STD_LOGIC_VECTOR(599 DOWNTO 0);
		red       : OUT STD_LOGIC;
		green     : OUT STD_LOGIC;
		blue      : OUT STD_LOGIC
	);
END noteColumn;

ARCHITECTURE Behavioral OF notecolumn IS
	CONSTANT size  : INTEGER := 8;
	SIGNAL note_on : STD_LOGIC; -- indicates whether ball is over current pixel position
	SIGNAL note_col : STD_LOGIC_VECTOR(599 DOWNTO 0) := (OTHERS => '0');
	-- current ball position - intitialized to center of screen
    SIGNAL counter : STD_LOGIC_VECTOR(25 downto 0);
    SIGNAL new_note : STD_LOGIC;
    SIGNAL local_clk: STD_LOGIC;
BEGIN

	red <= '1'; -- color setup for red ball on white background
	green <= NOT note_on;
	blue  <= NOT note_on;
	
	-- process to draw note current pixel address is covered by ball position
	ndraw : PROCESS (note_input, note_col, pixel_row, pixel_col) IS
	BEGIN
		
		IF note_input = '1' then
		  new_note <= '1';
	    ELSE
	      new_note <= '0';
	    END IF;
		
		IF pixel_col >= horiz - size AND
		   pixel_col <= horiz + size THEN
			FOR i IN 0 TO 14 LOOP
				IF CONV_INTEGER(pixel_row) + i - 7 >= 0 AND
				   CONV_INTEGER(pixel_row) + i - 7 < 600 AND
				   note_col(CONV_INTEGER(pixel_row) + i - 7) = '1' THEN
					note_on <= '1';
					EXIT;
				END IF;
			END LOOP;
		ELSE
			note_on <= '0';
		END IF;
		END PROCESS;
		
    count : PROCESS
    BEGIN
        WAIT UNTIL rising_edge(clk);
            counter <= counter + 1;
            local_clk <= counter(20);
    END PROCESS;
            
    -- process to move note at some division of the clock speed (i.e. once every vsync pulse)
    mcolumn : PROCESS(local_clk)
    BEGIN
    IF rising_edge(local_clk) THEN  
        note_col(599 downto 1) <= note_col(598 downto 0);
    
        IF new_note = '1' THEN
            note_col(0) <= '1';
        else
            note_col(0) <= '0';
        END IF;
    END IF;
    END PROCESS;
		
END Behavioral;