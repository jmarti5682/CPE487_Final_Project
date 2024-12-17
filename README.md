# CPE487: Final_Project
**By: Caleb Romero and Jose Martinez-Ponce** 

A guitar hero style game done on a FPGA device via VHDL



## 1. Project Overview

The main goal of this project was to create a Guitar Hero-style rhythm game using the Nexys A7 board, VGA display, and a keypad module to simulate guitar inputs. The project aimed to replicate core aspects of Guitar Hero, including note timing, input detection, scoring, and combo multipliers.

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

## Attachments and Requirements
  * Nexys A7 Board 100T
    - 
  * VGA Cable
  * Keypad Module
  * Micro USB Cable (Used for power)
  * AMD Vivado™ Design Suite 

