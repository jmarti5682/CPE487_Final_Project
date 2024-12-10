LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY ball IS
	PORT 
	(
		v_sync : IN STD_LOGIC;
		pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);

		red : OUT STD_LOGIC;
		green : OUT STD_LOGIC;
		blue : OUT STD_LOGIC
	);
END ball;

ARCHITECTURE Behavioral OF ball IS
	CONSTANT num_balls : INTEGER := 4; -- NUMBER of balls
	CONSTANT size : INTEGER := 20; -- Size of each ball
	SIGNAL ball_on : STD_LOGIC; -- indicates whether ball is over current pixel position

-- Ball Attributes  (easier to set "settings" for each ball)
	TYPE ball_position_arr IS ARRAY (0 TO num_balls - 1) OF STD_LOGIC_VECTOR(10 DOWNTO 0);
	TYPE ball_on_array IS ARRAY (0 TO num_balls - 1) OF STD_LOGIC;

	SIGNAL ball_x : ball_position_array := (
		CONV_STD_LOGIC_VECTOR(100, 11), -- ball 1 x
		CONV_STD_LOGIC_VECTOR(200, 11), -- ball 2 x
		CONV_STD_LOGIC_VECTOR(300, 11), -- ball 3 x
		CONV_STD_LOGIC_VECTOR(400, 11), -- ball 4 x
	);

	SIGNAL ball_y : ball_position_array := (
		CONV_STD_LOGIC_VECTOR(0, 11), -- ball 1 y
		CONV_STD_LOGIC_VECTOR(0, 11), -- ball 2 y
		CONV_STD_LOGIC_VECTOR(0, 11), -- ball 3 y
		CONV_STD_LOGIC_VECTOR(0, 11), -- ball 4 y
	);

-- current ball position - intitialized to center of screen
	--SIGNAL ball_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
	--SIGNAL ball_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);

-- current ball motion - initialized to +4 pixels/frame
	--SIGNAL ball_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000100";
	SIGNAL ball_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000100";
	SIGNAL ball_on : ball_on_array;
	BEGIN
		red <= NOT ball_on; -- color setup for red ball on white background
		green <= '1'; --NOT ball_on;
		blue <= '1'; --NOT ball_on;


	-- process to draw ball current pixel address is covered by ball position
	bdraw : PROCESS (pixel_row,pixel_col)
	BEGIN
		-- (ball_x-pixel_col)^2 + (ball_ypixel_row)^2 = size^2
		FOR i IN 0 TO num_balls - 1 LOOP
			IF ((conv_integer(ball_x(i)) - conv_integer(pixel_col))**2 + 
			(conv_integer(ball_y(i)) - conv_integer(pixel_row))**2 
			<= size**2) THEN
				ball_on(i) <= '1';
			ELSE
				ball_on(i) <= '0';
			END IF;
		END LOOP;
	END PROCESS;
			-- process to move ball once every frame (i.e. once every vsync pulse)
	mball : PROCESS
	BEGIN
		WAIT UNTIL rising_edge(v_sync);
		FOR i IN 0 TO num_balls-1 LOOP
			-- Move ball down
			ball_y(i) <= ball_y(i) + ball_y_motion;

			-- Reset ball to the top if it goes off the bottom of the screen
			IF conv_integer(ball_y(i)) >= screen_height THEN
				ball_y(i) <= CONV_STD_LOGIC_VECTOR(0, 11); -- Reset Y to the top
				-- Optionally, randomize or cycle the X position for variety
				ball_x(i) <= CONV_STD_LOGIC_VECTOR((conv_integer(ball_x(i)) + 200) MOD screen_width, 11);
		END IF;
		END LOOP;
	END PROCESS;
END Behavioral;
