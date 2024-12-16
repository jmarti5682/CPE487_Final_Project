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
		bt_down : IN STD_LOGIC; -- down button onboard
        KB_col : OUT STD_LOGIC_VECTOR (4 DOWNTO 1); -- keypad column pins
	    KB_row : IN STD_LOGIC_VECTOR (4 DOWNTO 1) -- keypad row pins
    );
END vga_top;

ARCHITECTURE Behavioral OF vga_top IS
    CONSTANT song_map1 : STD_LOGIC_VECTOR(599 DOWNTO 0) := 
        "000000000000000000000000001000000000000010010000000001000000" &
        "000000000000000000000000000000000000000100000000000000000000" &
        "000010000000000000000000000000000000000100100000000001000000" &
        "000000000000000000000000000000000000000000100000000000000000" &
        "000000000000000000100000000000000000000000000000100000000000" &
        "000000000000000000000000000000000000000000000000000001000000" &
        "000000000000000000000000010000000000000100000000000000000000" &
        "000000000000000000000000000000000000000000000000000001000000" &
        "000000000000000000000000010000000000000000000000000000000000" &
        "000000000000000000000000000000000000000100000000000000000000";

    CONSTANT song_map2 : STD_LOGIC_VECTOR(599 DOWNTO 0) := 
        "000000000000000000000000000000000000000100000000000000000000" &
        "000000000000000000100000000000000000000000000000100000000000" &
        "000000000000000000000000000000000000000000000000000001000000" &
        "000000000000000000000000000000000000000000000000000000100000" &
        "000000000000000000000000000000000000000000000000000000000000" &
        "000000000000000000000000010000000000000100000000000000000000" &
        "000000000000000000000000000000000000000000000000000001000000" &
        "000000000000000000000000010000000000000000000000000000000000" &
        "000000000000000000000000000000000000000000000000000001000000" &
        "000000000000000000000000000000000000000000000000000000000000";
     
     CONSTANT song_map3 : STD_LOGIC_VECTOR(599 DOWNTO 0) := 
        "000000000000000000000000000000000000000100000000000000000000" &
        "000000000000000000100000000000000000000000000000000000000000" &
        "000000000000000000000000000000000000000000000000000001000000" &
        "000000100000000000000000000000000000000000000000000000100000" &
        "000000000000000000000000000000000000000000000000000000000000" &
        "000000000000000000000000010000000000000000000000000000000000" &
        "000000000000000000000000000000000000000100000000000001000000" &
        "000000000000000000000000010000000000000000000000000000000000" &
        "000000000000000000100000000000000000000000000000000001000000" &
        "000000000000000000000000000000000000000000000000000000000000";
     
     CONSTANT song_map4 : STD_LOGIC_VECTOR(599 DOWNTO 0) := 
        "000000000000000000000000000000000000000100000000000000000000" &
        "000000000000000000100000000000000000000000000000100000000000" &
        "000000000000000000000000000000000000000000000000000001000000" &
        "000000000000000000000000000000000000000000000000000000100000" &
        "000000000000000000000000000000000000000000000000000000000000" &
        "000000000000000000000000010000000000000100000000000000000000" &
        "000000000000000000000000000000000000000000000000000001000000" &
        "000000000000000000000000010000000000000000000000000000000000" &
        "000000000000000000000000000000000000000000000000000001000000" &
        "000000000000000000000000000000000000000000000000000000000000";
        
    SIGNAL note1_active : STD_LOGIC;
    SIGNAL note2_active : STD_LOGIC;
    SIGNAL note3_active : STD_LOGIC;
    SIGNAL note4_active : STD_LOGIC;

    SIGNAL pxl_clk : STD_LOGIC;
    -- internal signals to connect modules
    SIGNAL S_red, S_green, S_blue : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL fin_red, fin_green, fin_blue : STD_LOGIC;
    SIGNAL S_vsync, kp_clk : STD_LOGIC;
    SIGNAL S_pixel_row, S_pixel_col : STD_LOGIC_VECTOR (10 DOWNTO 0);
    SIGNAL Note_column1, Note_column2, Note_column3, Note_column4 : STD_LOGIC_VECTOR(599 downto 0);
    SIGNAL cnt : std_logic_vector(20 DOWNTO 0);
    SIGNAL keypresses : Std_logic_vector(3 DOWNTO 0);
    SIGNAL score_out : std_logic_vector(15 DOWNTO 0);
    SIGNAL hit_signals_out, hit_signals_back : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL game_state : STD_LOGIC;
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
    
    COMPONENT songMap is
        GENERIC (
        song_map : STD_LOGIC_VECTOR(599 DOWNTO 0) -- Song map for the column
        );
        
        PORT (
        clk          : IN  STD_LOGIC;  -- Clock input
        reset        : IN  STD_LOGIC;  -- Reset signal to restart the song
        song_pointer : OUT INTEGER RANGE 0 TO 599; -- Current pointer in the song map
        note_active  : OUT STD_LOGIC   -- Indicates if a note is active at the current pointer
        );
    END COMPONENT;
    
    COMPONENT homescreen is
        port(
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            start_game : IN STD_LOGIC;
            back_to_menu : IN STD_LOGIC;
            current_state : OUT STD_LOGIC
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
    ck_proc : process(clk_in)
    BEGIN
    IF rising_edge(clk_in) THEN -- on rising edge of clock
			cnt <= cnt + 1; -- increment counter
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
        note_input => note1_active,
        hit_signal_in => hit_signals_out(0),
        note_col_out   => note_column1,
        color => "011",
        keypress => keypresses(0),
        hit_signal_out => hit_signals_back(0),
        red        => S_red(0), 
        green      => S_green(0), 
        blue       => S_blue(0)
    );
    red_note : noteColumn
    PORT MAP(
        --instantiate ball component
        clk        => clk_in,
        v_sync     => S_vsync, 
        pixel_row  => S_pixel_row, 
        pixel_col  => S_pixel_col, 
        horiz      => conv_std_logic_vector(320,11),
        note_input => note2_active,
        hit_signal_in => '1',
        note_col_out   => note_column2,
        color => "100",
        keypress => keypresses(1),
        hit_signal_out => hit_signals_back(1),
        red        => S_red(1), 
        green      => S_green(1), 
        blue       => S_blue(1)
    );
    
--     purple_note : noteColumn
--    PORT MAP(
--        --instantiate ball component
--        clk        => clk_in,
--        v_sync     => S_vsync, 
--        pixel_row  => S_pixel_row, 
--        pixel_col  => S_pixel_col, 
--        horiz      => conv_std_logic_vector(480,11),
--        note_input => note3_active,
--        hit_signal_in => '1',
--        note_col_out   => note_column3,
--        color => "101",
--        keypress => keypresses(1),
--        hit_signal_out => hit_signals_back(2),
--        red        => S_red(2), 
--        green      => S_green(2), 
--        blue       => S_blue(2)
--    );
   
    
--    blue_note : noteColumn
--    PORT MAP(
--        --instantiate ball component
--        clk        => clk_in,
--        v_sync     => S_vsync, 
--        pixel_row  => S_pixel_row, 
--        pixel_col  => S_pixel_col, 
--        horiz      => conv_std_logic_vector(640,11),
--        note_input => note4_active,
--        hit_signal_in => hit_signals_out(0),
--        note_col_out   => Note_column4,
--        color => "110",
--        keypress => keypresses(3),
--        red        => S_red(3), 
--        green      => S_green(3), 
--        blue       => S_blue(3)
--    );


    songMap1 : songMap
    GENERIC MAP (
        song_map => song_map1
    )
    PORT MAP (
        clk => clk_in,
        reset => bt_clr,
        song_pointer => open, -- Use `open` if you don't need the signal
        note_active => note1_active
    );

    songMap2 : songMap
    GENERIC MAP (
        song_map => song_map2
    )
    PORT MAP (
        clk => clk_in,
        reset => bt_clr,
        song_pointer => open, -- Use `open` if unused
        note_active => note2_active
    );
    
--    songMap3 : songMap
--    GENERIC MAP (
--        song_map => song_map3
--    )
--    PORT MAP (
--        clk => clk_in,
--        reset => bt_clr,
--        song_pointer => open, -- Use `open` if unused
--        note_active => note3_active
--    );
    
--    songMap4 : songMap
--    GENERIC MAP (
--        song_map => song_map4
--    )
--    PORT MAP (
--        clk => clk_in,
--        reset => bt_clr,
--        song_pointer => open, -- Use `open` if unused
--        note_active => note4_active
--    );
    
    
    
--    home_screen : homescreen
--    port map(
--        clk => clk_in,
--        reset => bt_down,
--        start_game => keypresses(0),
--        back_to_menu => keypresses(1),
--        current_state => game_state
--    );
    
    add_keypad : keypad
    PORT MAP(
    samp_ck => kp_clk,
    col => kb_col,
	row => kb_row,
	keypress_out => keypresses
	--hit
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
    
    button_track : buttonTracker
    PORT MAP(
        clk => clk_in,
        keypress => keypresses,
        note_col_1 => note_column1,
        note_col_2 => note_column2,
        note_col_3 => (others => '0'),
        note_col_4 => (others => '0'),
        hit_signal_1 => hit_signals_out(0),
        hit_signal_2 => hit_signals_out(1),
        hit_signal_3 => hit_signals_out(2),
        hit_signal_4 => hit_signals_out(3),
        hit_sigB_1 => hit_signals_back(0),
        hit_sigB_2 => hit_signals_back(1),
        hit_sigB_3 => '0',
        hit_sigB_4 => '0',
        score => score_out
    );
    
    vga_vsync <= S_vsync; --connect output vsync
        
    clk_wiz_0_inst : clk_wiz_0
    port map (
      clk_in1 => clk_in,
      clk_out1 => pxl_clk
    );
    
    
END Behavioral;
