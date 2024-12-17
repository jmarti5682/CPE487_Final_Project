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
