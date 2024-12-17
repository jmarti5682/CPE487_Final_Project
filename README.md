# CPE487: Final_Project - Guitar Hero
**By: Caleb Romero and Jose Martinez-Ponce** 

A guitar hero style game done on a FPGA device via VHDL



## 1. Project Overview

The main goal of this project was to create a Guitar Hero-style rhythm game using the Nexys A7 board, VGA display, and a keypad module to simulate guitar inputs. The project aimed to replicate core aspects of Guitar Hero, including note timing, input detection, scoring, and combo multipliers.

### Dummy Gameplay

<img src="images/IMG_8287.gif" alt="gameplay" width="500"/>

***This is still a work in progress***

How to Play:
* Due to the early stage of the game, notes have to be manually spawned in
* Use the bottom row of the keypad to 'hit' notes
  - 0, F, E, D for each respective column
* To spawn manual note use:
  - BTNL, BTND, BTNR, BTNU
 
<img src="images/IMG_8289.gif" alt="gameplay" width="500"/>
 
#### NOTE: ONLY THE FIRST TWO COLUMNS WORK AS OF THIS MOMENT

### Key Aspects of Guitar Hero:

#### Notes Falling on the Screen:

* Notes descend from the top of the screen to the bottom, where they align with target zones.

* The player interacts with the game by pressing corresponding buttons on the keypad, acting as the guitar.

#### Rhythm Detection:

* The closer the player is to hitting the note on the beat, the more points they receive.

* The visual indicator for timing accuracy is how well the note aligns with the bottom oval shape.

#### Scoring System:

* Points are awarded based on successful note hits.

* A combo system increases the player's score multiplier for consecutive correct inputs, rewarding precision and rhythm.

#### Keypad as Guitar Input:

* Four buttons on the keypad act as inputs for the game, simulating the Guitar Hero guitar.

* The project integrates the keypad module for inputs and the VGA display for visual output to create a functional rhythm game inspired by Guitar Hero.

##### Reference of Guitar Hero
![Guitar Hero](https://i.ytimg.com/vi/UHaQSiHoNL8/maxresdefault.jpg)


## 2. Expected Behavior


* Notes descend vertically on the VGA display towards target zones.

* When a note reaches the bottom oval shape and the user presses the corresponding button, the following occurs:

  - The note is deleted from the screen to indicate a successful hit.
  
  - The player's score is updated, rewarding the user for hitting the note on rhythm.
  
* This process repeats for each individual column of notes (4 total notes column streaming down).

* Visual feedback is provided through:

    * Button color change: When a user presses a button, its color changes to visually indicate the input.

* Score Display: The player's updated score is shown on the FPGA board's display.

* Correct inputs increase the score, while missed notes break the combo multiplier.

## 3. Attachments and Requirements

In order to run and implement the project successfully, the following hardware and software is required:

  * Nexys A7 Board 100T
    
  <img src="images/100t.png" alt="Nexys A7 Board 100T" width="300"/>
  
  * VGA Cable
    
  <img src="images/vga.png" alt="VGA cable" width="300"/>
  
  * Keypad Module
    
  <img src="images/keypad.png" alt="keypad" width="300"/>

  * Micro USB Cable (Used for power)
    
  <img src="images/microusb.jpg" alt="microusb" width="300"/> 
  
  * AMD Vivado™ Design Suite

## 4. Setup

Download the following files from the repo to your computer:
* `ball.vhd`
* `buttonTracker.vhd`
* `clk_wiz_0.vhd`
* `clk_wiz_0_clk_wiz.vhd`
* `keypad.vhd`
* `leddec16.vhd`
* `songMap.vhd`
* `vgaCombiner.vhd`
* `vga_sync.vhd`
* `vga_top.vhd`
* `vga_top.xdc`

Once you have downloaded those files, follow these steps:
1. Open **AMD Vivado™ Design Suite** and create a new project
2. Add all the `.vhd` files into the source section
3. Add `vga_top.xdc` into the constraints section
4. Choose Nexys A7-100T board
5. Run Synthesis
6. Run the implementation
7. Generate the bitstream
8. Open Hardware manager
    - `Open Target`
    - `Auto Connect`
    - `Program Device`
9. Start to manually spawn in notes and "catch" them

## 5. Modules

![module](/images/module.png)

## 6. Inputs and Outputs

### `vga_top.vhd`
```
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
```

#### Inputs
- clk_in: System Clock
- bt_clr: Center button input, meant to restart the game
- bt_strt: Left button input, spawns note for first column
- bt_strt1: Down button input, spawns note for second column
- bt_strt2: Right button input, spawns note for third column
- bt_strt3: Up button input, spawns note for fourth column
- KB_row: Keypad row signals, used for detecting user input on the keypad

#### Outputs
 - vga_red: VGA singal controlling the **red** color inensity for the display
 - vga_green: VGA singal controlling the **green** color intensity for the display
 - vga_blue: VGA signal controlling the **blue** color intensity for the display
 - vga_hsync: Horiztonal sync signal for the VGA display
 - vga_vsync: Vertical sync signal for the VGA display
 - SEG7_anode: Controls the anodes of the 7-segment displays
 - SEG7_seg: Controls the segments of the 7-segment display
 - KB_col: keypad column signals, used to scan for keypresses on the keypad
   

### `ball.vhd`
```
ENTITY noteColumn IS
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
END noteColumn;
```
#### Inputs
 - clk: System Clock
 - v_sync: vertical sync signal
 - pixel_row: current row pixel position of VGA
 - pixel_col: current column pixel position of VGA
 - horiz: Horitzontal position where note column is drawn
 - note_input: Input signal indicating a new note should be created
 - hit_signal_in: Input signal indicating the note was successfully hit
 - color: Input color value for the note and note column
 - keypress: Input signal indicating that the user pressed the key/button

#### Outputs
 - hit_signal_out: Output signal indicating the note was hit and cleared
 - note_col_out: Vector output representing the state of the note column
 - red: Red color signal
 - green: Green color signal
 - blue: Blue color signal

### `buttonTracker.vhd`
```
entity buttonTracker is
    PORT (
        clk          : IN  STD_LOGIC;
        reset        : IN  STD_LOGIC;
        keypress     : IN  STD_LOGIC; -- 4 keypad inputs
        note_col_1   : IN  STD_LOGIC_VECTOR(599 DOWNTO 0); -- Falling notes from column 1
        hit_sigB_1 : IN STD_LOGIC;
        hit_signal_1 : OUT STD_LOGIC; -- Signal to delete notes
        score        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- Score output
    );
end buttonTracker;
```
#### Inputs
 - clk: System Clock
 - reset: Reset Signal to clear the score and reset internal states
 - keypress: Indicates if a button/key on the keypad has been pressed
 - note_col_1: Falling notes in column X, represented as a vector of 600 bits
 - hit_sigB_1: Signal indicating a hit event, which clears a note in the falling column

#### Outputs
 - hit_signal_1: Output signal to delete notes in column X after a successful hit
 - score: Current score output as a 32-bit vector, updated upon successful hits

### `vgaCombiner.vhd`
```
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
```
#### Inputs
 - clk: System Clock
 - red_inputs: 4-bit input for red color channels
 - green_inputs: 4-bit input for green color channels
 - blue_inputs: 4-bit input for blue color channels

#### Outputs
 - red_out: Combined red output color
 - green_out: Combined green output color
 - blue_out: Combined blue output color


### `songMap`
```
ENTITY songMap IS
    GENERIC (
        song_map : STD_LOGIC_VECTOR(599 DOWNTO 0) -- Song map for the column
    );
    PORT (
        clk          : IN  STD_LOGIC;  -- Clock input
        reset        : IN  STD_LOGIC;  -- Reset signal to restart the song
        song_pointer : OUT INTEGER RANGE 0 TO 599; -- Current pointer in the song map
        note_active  : OUT STD_LOGIC   -- Indicates if a note is active at the current pointer
    );
END songMap;
```
#### Inputs
 - clk: System Clock
 - reset: Reset signal to restart the song pointer back to the beginning

#### Outputs
 - song_pointer: Indicates the current position/pointer in the `song_map`
 - note_active: Indicates whether a note is active at the current pointer position

#### Generics
 - song_map: A 600-bit vector representing the song map for a single note column. Each bit corresponds to a note position

## 7. Modifications

### `ball.vhd`

The note funtionally behind our program was based off `ball.vhd` from lab 3. We have modified `ball.vhd` to be anything from a bouncing ball, as we  generalized it to become falling notes. Instead of just one "ball" bouncing vertically, the logic was futher extended to handle falling notes from the top of the screen to the bottom. In addition, this allowed to have notes appear at fixed horizontal positions (columns) and move downwards. As well, we also changed the logic on how color is assigned to the ball.

We removed the logic of bouncing off the bottom of the screen, as we just wanted to have a note to fall downward only. 

#### Modified Code: 

```
-- Determine if the current pixel aligns with a falling note position
ndraw : PROCESS (note_input, note_col, pixel_row, pixel_col)
BEGIN
    IF note_input = '1' THEN
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
```
#### Changes: 
*Modified:* We added a check for falling notes based on column position (`hotiz`) and a vector (`note_col`) representing note activity in the song. 

```
mcolumn : PROCESS(local_clk)
BEGIN
    IF rising_edge(local_clk) THEN  
        -- Shift note positions down by 1
        note_col(599 DOWNTO 1) <= note_col(598 DOWNTO 0);
        
        IF new_note = '1' THEN
            note_col(0) <= '1'; -- Add a new note at the top
        ELSE
            note_col(0) <= '0';
        END IF;

        -- Delete notes if hit signal is received
        IF hit_signal_in = '1' THEN
            note_col(580 DOWNTO 550) <= (OTHERS => '0');
            hit_signal_out <= '1';
        ELSE
            hit_signal_out <= '0';
        END IF;
    END IF;
END PROCESS;
```
#### Changes: 
*Modified:* Notes move downward continuously by shifting the `note_col` vector. New notes can be added at the top, and notes are deleted when a hit signal is recieved. 

```
IF note_on = '0' THEN
    red <= '1';
    green <= '1';
    blue <= '1';
END IF;

IF note_on = '1' THEN
    red <= color(2);
    green <= color(1);
    blue <= color(0);
END IF;

-- Visual feedback for keypress
IF keypress = '1' AND condition THEN
    red <= '0';
    green <= '0';
    blue <= '0';
END IF;
```
#### Changes: 
*Modified:* Notes can have dynamic colors using an input `color` vector, and feedback is provided for a keypress (note turns black).
