library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

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
		bt_strt : IN STD_LOGIC;
		bt_strt1 : IN STD_LOGIC;
		bt_strt2 : IN STD_LOGIC;
		bt_strt3 : IN STD_LOGIC;
        KB_col : OUT STD_LOGIC_VECTOR (4 DOWNTO 1); -- keypad column pins
	    KB_row : IN STD_LOGIC_VECTOR (4 DOWNTO 1) -- keypad row pins
    );
END vga_top;

ARCHITECTURE Behavioral OF vga_top is
    SIGNAL pxl_clk : STD_LOGIC;
    -- internal signals to connect modules
    SIGNAL S_red, S_green, S_blue : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL fin_red, fin_green, fin_blue : STD_LOGIC;
    SIGNAL S_vsync, kp_clk : STD_LOGIC;
    SIGNAL S_pixel_row, S_pixel_col : STD_LOGIC_VECTOR (10 DOWNTO 0);
    SIGNAL Note_column1, Note_column2, Note_column3, Note_column4 : STD_LOGIC_VECTOR(599 downto 0);
    SIGNAL cnt : std_logic_vector(32 DOWNTO 0);
    SIGNAL keypresses : Std_logic_vector(3 DOWNTO 0);
    SIGNAL total_score,blue_score, red_score, green_score, purple_score : std_logic_vector(31 DOWNTO 0);
    SIGNAL hit_signals_out, hit_signals_back : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL s_red1, s_red2, s_red3, s_red4 : STD_LOGIC;
    SIGNAL s_green1, s_green2, s_green3, s_green4 : STD_LOGIC;
    SIGNAL s_blue1, s_blue2, s_blue3, s_blue4 : STD_LOGIC;
    COMPONENT noteColumn IS
        PORT (
        clk       : IN STD_LOGIC;
		v_sync    : IN STD_LOGIC;
		pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		horiz     : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		note_input: IN STD_LOGIC;
		hit_signal_in : IN std_logic;
		color : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		keypress     : IN STD_LOGIC;
		hit_signal_out : OUT STD_LOGIC;
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

    COMPONENT colorCombiner IS
    PORT (
        clk          : IN STD_LOGIC;
        red_inputs   : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Supports up to 8 columns
		green_inputs : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		blue_inputs  : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		red_out      : OUT STD_LOGIC;
		green_out    : OUT STD_LOGIC;
		blue_out     : OUT STD_LOGIC
    );
END COMPONENT;
    
    COMPONENT buttonTracker IS
    PORT (
        clk          : IN  STD_LOGIC;
        reset        : IN  STD_LOGIC;
        keypress     : IN  STD_LOGIC; -- 4 keypad inputs
        note_col_1   : IN  STD_LOGIC_VECTOR(599 DOWNTO 0); -- Falling notes from column 1
        hit_sigB_1 : IN STD_LOGIC;
        hit_signal_1 : OUT STD_LOGIC; -- Signal to delete notes
        score        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- Score output
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
			dig : IN STD_LOGIC_VECTOR (19 DOWNTO 17);
			data : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
		);
END COMPONENT;
    
BEGIN
    -- vga_driver only drives MSB of red, green & blue
    -- so set other bits to zero
    ck_proc : process(clk_in)
    BEGIN
    IF rising_edge(clk_in) THEN -- on rising edge of clock
			cnt <= cnt + 1; -- increment counter
			total_score <= blue_score + red_score + green_score + purple_score;
			
			s_red(0) <= s_red1;
			s_red(1) <= s_red2;
			s_red(2) <= s_red3;
			s_red(3) <= s_red4;
			
			s_green(0) <= s_green1;
            s_green(1) <= s_green2;
            s_green(2) <= s_green3;
            s_green(3) <= s_green4;
            
            s_blue(0) <= s_blue1;
            s_blue(1) <= s_blue2;
            s_blue(2) <= s_blue3;
            s_blue(3) <= s_blue4;
			
		END IF;
    END PROCESS;
    vga_red(1 DOWNTO 0) <= "00";
    vga_green(1 DOWNTO 0) <= "00";
    vga_blue(0) <= '0';
    
    kp_clk <= cnt(8);
    
    s_red(3 downto 2) <= "11";
    s_green(3 downto 2) <= "11";
    s_blue(3 downto 2) <= "11";
    
    green_note : noteColumn
    PORT MAP(
        --instantiate ball component
        clk        => clk_in,
        v_sync     => S_vsync, 
        pixel_row  => S_pixel_row, 
        pixel_col  => S_pixel_col, 
        horiz      => conv_std_logic_vector(160,11),
        note_input      => bt_strt1,
        hit_signal_in => hit_signals_out(0),
        note_col_out   => note_column1,
        color => "010",
        keypress => keypresses(0),
        hit_signal_out => hit_signals_back(0),
        red        => S_red1, 
        green      => S_green1, 
        blue       => S_blue1
    );
    red_note : noteColumn
    PORT MAP(
        --instantiate ball component
        clk        => clk_in,
        v_sync     => S_vsync, 
        pixel_row  => S_pixel_row, 
        pixel_col  => S_pixel_col, 
        horiz      => conv_std_logic_vector(320,11),
        note_input      => bt_strt,
        hit_signal_in => hit_signals_out(1),
        note_col_out   => note_column2,
        color => "100",
        keypress => keypresses(1),
        hit_signal_out => hit_signals_back(1),
        red        => S_red2, 
        green      => S_green2, 
        blue       => S_blue2
    );
    purple_note : noteColumn
    PORT MAP(
        --instantiate ball component
        clk        => clk_in,
        v_sync     => S_vsync, 
        pixel_row  => S_pixel_row, 
        pixel_col  => S_pixel_col, 
        horiz      => conv_std_logic_vector(480,11),
        note_input      => bt_strt2,
        hit_signal_in => hit_signals_out(2),
        note_col_out   => note_column3,
        color => "101",
        keypress => keypresses(2),
        hit_signal_out => hit_signals_back(2),
        red        => S_red3, 
        green      => S_green3, 
        blue       => S_blue3
    );
    blue_note : noteColumn
    PORT MAP(
        --instantiate ball component
        clk        => clk_in,
        v_sync     => S_vsync, 
        pixel_row  => S_pixel_row, 
        pixel_col  => S_pixel_col, 
        horiz      => conv_std_logic_vector(640,11),
        note_input      => bt_strt3,
        hit_signal_in => hit_signals_out(3),
        note_col_out   => note_column4,
        color => "011",
        keypress => keypresses(3),
        hit_signal_out => hit_signals_back(3),
        red        => S_red4, 
        green      => S_green4, 
        blue       => S_blue4
    );
    
    add_keypad : keypad
    PORT MAP(
    samp_ck => kp_clk,
    col => kb_col,
	row => kb_row,
	keypress_out => keypresses
	--hit
    );
    display : leddec16
    PORT MAP(
        dig => cnt(19 downto 17),
		data => total_score,
		anode => SEG7_anode,
		seg => SEG7_seg
    );
    vga_combine : colorCombiner
    PORT MAP(
        clk => clk_in,
        red_inputs => S_red, 
		green_inputs => S_green,
		blue_inputs => S_blue,
		red_out => fin_red,  
		green_out => fin_green,
		blue_out => fin_blue
    );
    
    vga_driver : vga_sync
    PORT MAP(
        --instantiate vga_sync component
        pixel_clk => pxl_clk, 
        red_in    => fin_red, 
        green_in  => fin_green, 
        blue_in   => fin_blue, 
        red_out   => vga_red(2), 
        green_out => vga_green(2), 
        blue_out  => vga_blue(1), 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        hsync     => vga_hsync, 
        vsync     => S_vsync
    );
    
    green_button_track : buttonTracker
    PORT MAP(
        clk => clk_in, 
        reset => bt_clr,  
        keypress => keypresses(0),
        note_col_1 => note_column1,
        hit_sigB_1 => hit_signals_back(0),
        hit_signal_1 => hit_signals_out(0),
        score => green_score
    );
    
    red_button_track : buttonTracker
    PORT MAP(
        clk => clk_in,
        reset => bt_clr,   
        keypress => keypresses(1),
        note_col_1 => note_column2,
        hit_sigB_1 => hit_signals_back(1),
        hit_signal_1 => hit_signals_out(1),
        score => red_score
    );
    
    purple_button_track : buttonTracker
    PORT MAP(
        clk => clk_in,
        reset => bt_clr,   
        keypress => keypresses(2),
        note_col_1 => note_column3,
        hit_sigB_1 => hit_signals_back(2),
        hit_signal_1 => hit_signals_out(2),
        score => purple_score
    );
    
    blue_button_track : buttonTracker
    PORT MAP(
        clk => clk_in,
        reset => bt_clr,   
        keypress => keypresses(3),
        note_col_1 => note_column4,
        hit_sigB_1 => hit_signals_back(3),
        hit_signal_1 => hit_signals_out(3),
        score => blue_score
    );
    
    vga_vsync <= S_vsync; --connect output vsync
        
    clk_wiz_0_inst : clk_wiz_0
    port map (
      clk_in1 => clk_in,
      clk_out1 => pxl_clk
    );
    
END Behavioral;