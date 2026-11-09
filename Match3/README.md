# Match 3

A match-3 puzzle game with colorful tiles, combos, a countdown timer and increasing levels. Part of [GameDevStudies](../README.md), written in [Lua](https://www.lua.org/) with [LÖVE](https://love2d.org/) following CS50's Introduction to Game Development.

## Run

Install LÖVE 11.x and run the game folder:

```
love Match3/match-3
```

## How to play

- Move the cursor over the 8×8 board and select a tile, then select a second tile in the same row or column to swap them.
- A swap that forms a line of 3+ identical tiles clears them, scores 50 points per tile, and new tiles fall in (chain reactions count too).
- A swap that forms no match is undone.
- Reach the level's score goal (`level × 1250`) before the 60-second timer runs out to advance.

| Key | Action |
| --- | --- |
| Arrow keys | Move cursor |
| `Enter` | Select / swap / cancel tile |
| `Esc` | Quit |

## Structure

- `match-3/main.lua` — window, virtual resolution (512×288) and state machine setup
- `match-3/src/states/` — `start`, `begin-game`, `play`, `game-over`
- `match-3/src/Board.lua`, `Tile.lua` — grid generation, match detection, falling tiles
- `match-3/lib/` — [push](https://github.com/Ulydev/push), [knife](https://github.com/airstruck/knife) (timers/tweens) and `class.lua`
- `chain-*`, `quads-*`, `swap-*`, `timer-*`, `tween-*` — step-by-step lecture snapshots
