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
	-- CONSTANT num_balls : INTEGER := 4;  -- NUMBER of balls
	CONSTANT oval_height : INTEGER := 30;  -- height of oval
	CONSTANT oval_width : INTEGER := 15;  -- width of oval

	CONSTANT screen_height : INTEGER := 600;  -- Screen Height
	CONSTANT screen_width : INTEGER := 800;  -- Screen Width

	CONSTANT bottom_position : INTEGER := 550;  -- Bottom button position (In Pixel)

	CONSTANT size : INTEGER := 20; -- Size of each ball

	SIGNAL ball_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR (400, 11);  -- Ball's X position
	SIGNAL ball_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR (0, 11);  -- Ball's Y Position
	SIGNAL ball_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR (4, 11);  -- Ball's Falling Speed
	SIGNAL ball_on : STD_LOGIC; -- indicates whether ball is over current pixel position
	SIGNAL oval_on : STD_LOGIC;


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
		IF ((conv_integer(ball_x) - conv_integer(pixel_col))**2 + 
		(conv_integer(ball_y) - conv_integer(pixel_row))**2 
		<= size**2) THEN
			ball_on <= '1';
		ELSE
			ball_on <= '0';
		END IF;

		-- Oval Shape

		IF ((conv_integer(ball_x) - conv_integer(pixel_col))**2 / oval_width**2 +
			(conv_integer(ball_y) - conv_integer(pixel_row))**2 / oval_height**2
			<= 1) THEN
			oval_on <= '1';
		ELSE
			oval_on <= '0';
		END IF;
	
-- Process to update ball position on every v_sync pulse
mball : PROCESS
BEGIN
	WAIT UNTIL rising_edge(v_sync);
	-- Move ball down
	ball_y <= ball_y + ball_y_motion;

	-- Reset ball to the top if it goes off the bottom of the screen
	IF conv_integer(ball_y) >= screen_height THEN
		ball_y <= CONV_STD_LOGIC_VECTOR(0, 11); -- Reset Y to the top
	END IF;
END PROCESS;


END PROCESS;
END Behavioral;
