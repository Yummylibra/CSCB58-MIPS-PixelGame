# CSCB58 Assembly Project – Platform Game

## Overview
This is my final project for **CSCB58: Computer Organization** at the UTSC, which is finished by myself merely within 5 days.
The goal was to design and implement a **platform game** entirely in **MIPS assembly**, using the MARS simulator with its **Bitmap Display** and **Keyboard MMIO** tools:contentReference[oaicite:0]{index=0}.

The game is a single-screen platformer where the player controls a character that can:
- Move left and right (`a`, `d` keys).
- Jump with double-jump ability (`w` key).
- Interact with platforms (static, moving, or disappearing).
- Avoid hazards (fire wheel, enemies, and lava at the bottom).
- Defeat enemies by jumping on their heads.
- Win by reaching the victory door, or lose when all hearts are depleted:contentReference[oaicite:1]{index=1}.

## Features Implemented
Milestones completed:
1. **Milestone 1**  
   - 64×64 framebuffer.  
   - Platforms: 4 static light-blue, 1 moving green, 1 vanishing purple.  
   - Objects: 2 enemies (green and red) and 1 moving fire wheel:contentReference[oaicite:2]{index=2}.

2. **Milestone 2**  
   - Player can move left, right, and jump.  
   - Gravity ensures the player falls automatically.  
   - Collision detection with enemies, fire wheel, and lava.  
   - Hearts decrease when the player is hurt:contentReference[oaicite:3]{index=3}.

3. **Milestone 3**  
   - HUD with lives displayed as hearts.  
   - Win condition: reaching the blue-yellow door.  
   - Lose condition: hearts reduced to 0.  
   - Enemies move horizontally and can be knocked out.  
   - Green platform moves horizontally.  
   - Purple platform disappears after some time.  
   - Double jump mechanic (max two jumps in air).  
   - Start menu (choose Start or Exit with `w`/`s`):contentReference[oaicite:4]{index=4}:contentReference[oaicite:5]{index=5}.

## Controls
- **a**: Move left  
- **d**: Move right  
- **w**: Jump (can double jump)  
- **s**: Menu navigation (exit)  
- **p**: Restart game  

## Technical Details
- **Bitmap Display**: 64×64 units, each 8×8 pixels.  
- **Base address**: `0x10008000`  
- **Colour encoding**: `0x00RRGGBB` (e.g., red = `0xff0000`):contentReference[oaicite:6]{index=6}.  
- **Keyboard input**: Polled from MMIO address `0xffff0000`.  

## Files
- `game.asm`: Full implementation of the platform game.  
- `gametest.asm`: Smaller test/demo version of certain mechanics.  
- `Assembly Project.pdf`: Original project description and requirements.  

## How to Run
1. Open `game.asm` in **MARS**.  
2. Configure **Bitmap Display**:  
   - Unit width = 8, Unit height = 8  
   - Display width = 512, Display height = 512  
   - Base address = `0x10008000`  
   - Click “Connect to MIPS”.  
3. Configure **Keyboard MMIO Simulator**:  
   - Base address = `0xffff0000`  
   - Click “Connect to MIPS”.  
4. Assemble and run the program.  
5. Use keyboard to control the game.

## Demo
Video demo link (private to course staff).  

---

**Course**: CSCB58 – Computer Organization (Winter 2023)  
**Language**: MIPS Assembly  
**Environment**: MARS Simulator (Bitmap Display + Keyboard MMIO)  
