LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY vga_top IS
    PORT (
        clk_in    : IN STD_LOGIC;
        vga_red   : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
        vga_green : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
        vga_blue  : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        vga_hsync : OUT STD_LOGIC;
        vga_vsync : OUT STD_LOGIC;
        SEG7_anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- anodes of eight 7-seg displays
		SEG7_seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0); -- common segments of 7-seg displays
		bt_clr : IN STD_LOGIC; -- calculator "clear" button
        KB_col : OUT STD_LOGIC_VECTOR (4 DOWNTO 1); -- keypad column pins
	    KB_row : IN STD_LOGIC_VECTOR (4 DOWNTO 1) -- keypad row pins
    );
END vga_top;

ARCHITECTURE Behavioral OF vga_top IS
    SIGNAL pxl_clk : STD_LOGIC;
    -- internal signals to connect modules
    SIGNAL S_red, S_green, S_blue : STD_LOGIC;
    SIGNAL S_vsync : STD_LOGIC;
    SIGNAL S_pixel_row, S_pixel_col : STD_LOGIC_VECTOR (10 DOWNTO 0);
    SIGNAL Note_column : STD_LOGIC_VECTOR(599 downto 0);
    COMPONENT noteColumn IS
        PORT (
            clk       : IN STD_LOGIC;
            v_sync    : IN STD_LOGIC;
            pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            horiz     : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            note_input: IN STD_LOGIC;
            note_col_out  : OUT STD_LOGIC_VECTOR(599 DOWNTO 0);
            red       : OUT STD_LOGIC;
            green     : OUT STD_LOGIC;
            blue      : OUT STD_LOGIC
        );
    END COMPONENT;
    COMPONENT vga_sync IS
        PORT (
            pixel_clk : IN STD_LOGIC;
            red_in    : IN STD_LOGIC;
            green_in  : IN STD_LOGIC;
            blue_in   : IN STD_LOGIC;
            red_out   : OUT STD_LOGIC;
            green_out : OUT STD_LOGIC;
            blue_out  : OUT STD_LOGIC;
            hsync     : OUT STD_LOGIC;
            vsync     : OUT STD_LOGIC;
            pixel_row : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
            pixel_col : OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT vgaCombiner IS
    PORT (
        red_inputs   : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Supports up to 8 columns
		green_inputs : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		blue_inputs  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		red_out      : OUT STD_LOGIC;
		green_out    : OUT STD_LOGIC;
		blue_out     : OUT STD_LOGIC
    );
END COMPONENT;
    
    COMPONENT buttonTracker IS
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
END COMPONENT;
    
    component clk_wiz_0 is
    port (
      clk_in1  : in std_logic;
      clk_out1 : out std_logic
    );
END COMPONENT;
    
    COMPONENT keypad IS
		PORT (
			samp_ck : IN STD_LOGIC;
			col : OUT STD_LOGIC_VECTOR (4 DOWNTO 1);
			row : IN STD_LOGIC_VECTOR (4 DOWNTO 1);
			value : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
			keypress_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
			hit : OUT STD_LOGIC
		);
END COMPONENT;
	
	COMPONENT leddec16 IS
		PORT (
			dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
		);
END COMPONENT;
    
BEGIN
    -- vga_driver only drives MSB of red, green & blue
    -- so set other bits to zero
    vga_red(1 DOWNTO 0) <= "00";
    vga_green(1 DOWNTO 0) <= "00";
    vga_blue(0) <= '0';

    add_ball : noteColumn
    PORT MAP(
        --instantiate ball component
        clk        => clk_in,
        v_sync     => S_vsync, 
        pixel_row  => S_pixel_row, 
        pixel_col  => S_pixel_col, 
        horiz      => conv_std_logic_vector(200,11),
        note_input => bt_clr,
        note_col_out   => Note_column,
        red        => S_red, 
        green      => S_green, 
        blue       => S_blue
    );

    vga_driver : vga_sync
    PORT MAP(
        --instantiate vga_sync component
        pixel_clk => pxl_clk, 
        red_in    => S_red, 
        green_in  => S_green, 
        blue_in   => S_blue, 
        red_out   => vga_red(2), 
        green_out => vga_green(2), 
        blue_out  => vga_blue(1), 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        hsync     => vga_hsync, 
        vsync     => S_vsync
    );
    vga_vsync <= S_vsync; --connect output vsync
        
    clk_wiz_0_inst : clk_wiz_0
    port map (
      clk_in1 => clk_in,
      clk_out1 => pxl_clk
    );
    
END Behavioral;