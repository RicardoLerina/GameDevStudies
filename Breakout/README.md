# Breakout

A Breakout clone with procedurally generated brick levels, selectable paddles, lives, particle effects and a persistent high-score table. Part of [GameDevStudies](../README.md), written in [Lua](https://www.lua.org/) with [LÖVE](https://love2d.org/) following CS50's Introduction to Game Development.

## Run

Install LÖVE 11.x and run the game folder:

```
love Breakout
```

To build a standalone Windows version (no LÖVE needed), run `build.ps1` from this folder. The output goes to `dist/`.

## How to play

- Pick a paddle color, then serve the ball and bounce it off the paddle to break every brick.
- Where the ball hits the paddle changes its bounce angle.
- Higher-tier and different-colored bricks are worth more points. Scoring enough points restores a heart.
- You have 3 hearts and lose one each time the ball falls off the bottom.
- Clearing all bricks advances to a harder level. A top-10 score lets you enter your initials.

| Key | Action |
| --- | --- |
| `←` / `→` | Move paddle / change selection |
| `↑` / `↓` | Navigate menu / change initial |
| `Enter` | Confirm, serve |
| `Space` | Pause / resume |
| `Esc` | Back / quit |

## Structure

- `main.lua` — assets, window, virtual resolution (432×243), state machine, high-score file (`breakout.lst` in LÖVE's save directory)
- `src/states/` — start, paddle select, serve, play, victory, game over, high scores
- `src/Ball.lua`, `Paddle.lua`, `Brick.lua`, `LevelMaker.lua` — game objects and level generation
- `lib/` — [push](https://github.com/Ulydev/push) and `class.lua`
