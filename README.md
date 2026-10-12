# GameDevStudies

A personal repository for learning game development. The projects follow the structure of Harvard's [CS50's Introduction to Game Development](https://cs50.harvard.edu/games/) (CS50 2D) and are written in [Lua](https://www.lua.org/) on top of the [LÖVE](https://love2d.org/) framework.

## Pong

A local two-player Pong remake with a retro pixel look, sound effects, a serve system and a first-to-10 win condition.

### Features

- **Virtual resolution:** the game renders at 432×243 and scales to a resizable 1280×720 window without blur, using [push](https://github.com/Ulydev/push) and nearest-neighbor filtering.
- **Game states:** `start` → `serve` → `play` → `done`, with on-screen prompts for each one.
- **Serve rule:** the player who conceded the last point serves next. After a match, the loser serves first.
- **Ball physics:** AABB collision with paddles and walls. Each paddle hit speeds the ball up by 3% and randomizes its vertical angle.
- **Frame-rate independence:** all movement is scaled by `dt`.
- **Audio:** sound effects for paddle hits, wall bounces and scoring.
- **FPS counter** in the top-left corner for debugging.

### Controls

| Action | Player 1 | Player 2 |
| --- | --- | --- |
| Move up | `W` | `↑` |
| Move down | `S` | `↓` |

| Key | Action |
| --- | --- |
| `Enter` | Start the game, serve, or restart after a win |
| `Esc` | Quit |

### Running the game

1. Install [LÖVE 11.x](https://love2d.org/).
2. From the repository root, run:

   ```sh
   love Pong
   ```

   On Windows you can also drag the `Pong` folder onto `love.exe`.

### Code structure

```
Pong/
├── main.lua      # Entry point: LÖVE callbacks, game state, scoring, input and rendering
├── Paddle.lua    # Paddle class: movement clamped to the screen, drawing
├── Ball.lua      # Ball class: AABB collision, reset, movement, drawing
├── class.lua     # hump.class, a small OOP library for Lua
├── push.lua      # push, a resolution-handling library
├── font.ttf      # Retro pixel font
└── sounds/       # paddle_hit.wav, score.wav, wall_hit.wav
```

---

## Credits

- Game design and base code from **CS50's Introduction to Game Development**, by Colton Ogden (Harvard University).
- [`push.lua`](Pong/push.lua) by Ulysse Ramage, MIT License.
- [`class.lua`](Pong/class.lua) (hump.class) by Matthias Richter, MIT-style license.

This repository is for educational purposes.
