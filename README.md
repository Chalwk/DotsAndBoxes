# Dots & Boxes - Love2D Android & Windows Game

A modern implementation of the classic pencil-and-paper game built with Love2D and Lua.

![Dots & Boxes](https://img.shields.io/badge/Love2D-2D%20Game%20Framework-E01A4F) ![License](https://img.shields.io/badge/License-MIT-green)

## 🎮 About the Game

Dots & Boxes is a classic strategy game where two players take turns drawing lines between dots on a grid. When a player
completes the fourth side of a box, they claim that box and get an extra turn. The player with the most boxes at the end
wins!

This implementation brings the classic game to life with:

- **Smooth animations** and visual effects
- **AI opponents** with multiple difficulty levels
- **Multiple board sizes** (3x3 to 6x6)
- **Beautiful particle backgrounds**
- **Move history** with undo functionality

## 🚀 How to Play

### Basic Rules

1. **Take Turns**: Players alternate drawing horizontal or vertical lines between dots
2. **Complete Boxes**: When you draw the fourth side of a box, you claim it and get another turn
3. **Score Points**: Each completed box earns one point
4. **Win Condition**: The player with the most boxes when all lines are drawn wins

### Controls

- **Left Click**: Draw a line (must click directly on a line between dots)
- **R**: Restart the current game
- **U**: Undo last move (in 2-player mode)
- **ESC**: Return to main menu
- **F1**: Toggle debug information