# Recon Game Library

This repository contains the source code for Recon Game Libary. The files are meant to be used in emu8086 microprocessor emulator and has not been tested elsewhere otherwise. 

The *assembly recongamelibrary vX.X.asm* files contains all the code from other components and version 1.0 contains the latest iteration of each component.

This project has been completed years ago and I have no intention on making any changes or whatsoever. 

Videos and images are available below for demonstration purposes.

## Components

### Menu

#### Usage Video
https://user-images.githubusercontent.com/46543419/151874335-5390aa25-4d9b-47a7-a5fc-720d58ecbd9c.mp4

<details>
  <summary><b>Screenshots</b></summary>
  <img src="docs/menu-nameprompt-image.png" alt="menu name prompt">
  <img src="docs/menu-image.png" alt="menu">
</details>

***
### Snake

#### Gameplay Video
https://user-images.githubusercontent.com/46543419/151874488-c78c2690-3e4f-44bd-ae1f-d44dffc5c5f0.mp4

<details>
  <summary><b>Screenshots</b></summary>
  <img src="docs/snake-instruction-image.png" alt="snake instructions">
  <img src="docs/snake-image.png" alt="snake">
</details>

***
### TicTacToe

#### Gameplay Video
https://user-images.githubusercontent.com/46543419/151874717-9d389d47-4928-4c0d-870a-8b3cb5b0d7ed.mp4

<details>
  <summary><b>Screenshots</b></summary>
  <img src="docs/tictactoe-instruction-image.png" alt="tictactoe instructions">
  <img src="docs/tictactoe-image.png" alt="tictactoe">
</details>

## Usage

- Load up the assembly file on emu8086.
  - File > Open > **assembly recongamelibrary v1.0.asm**
- Press **emulate** button on the toolbar.
- On the emulator window, press **run** button.
- **The first run will fail** and is expected. The second run should display a name prompt before the main menu.
  - Player name file is generated at: emu8086\vdrive\C\ReconGL\playerName.txt
- Both Main Menu and TicTacToe use mouse for input while both name changer and snake relies on keyboard. 
- Instructions are given for each game. Have fun!
