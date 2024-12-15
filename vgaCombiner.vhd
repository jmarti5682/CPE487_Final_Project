LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY colorCombiner IS
	PORT (
		red_inputs   : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Supports up to 8 columns
		green_inputs : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		blue_inputs  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		red_out      : OUT STD_LOGIC;
		green_out    : OUT STD_LOGIC;
		blue_out     : OUT STD_LOGIC
	);
END colorCombiner;

ARCHITECTURE Behavioral OF colorCombiner IS
BEGIN
	red_out <= '1' WHEN red_inputs /= (OTHERS => '0') ELSE '0';
	green_out <= '1' WHEN green_inputs /= (OTHERS => '0') ELSE '0';
	blue_out <= '1' WHEN blue_inputs /= (OTHERS => '0') ELSE '0';
END Behavioral;