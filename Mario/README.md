# Super 50 Bros.

A side-scrolling platformer in the style of Super Mario Bros.: run through a procedurally generated level, stomp snails, bump blocks from below and collect gems. Part of [GameDevStudies](../README.md), written in [Lua](https://www.lua.org/) with [LÖVE](https://love2d.org/) following CS50's Introduction to Game Development.

## Run

Install LÖVE 11.x and run the game folder:

```
love Mario/mario
```

To build a standalone Windows version (no LÖVE needed), run `build.ps1` from this folder. The output goes to `dist/`.

## How to play

- Walk and jump through a 100-tile level; falling into a pit or touching a snail from the side sends you back to the title screen.
- Land on a snail to kill it (+100).
- Jump into a block from below: it bounces, and about 1 in 5 hits reveals a gem (+100). A block only pays out once.

| Key | Action |
| --- | --- |
| Left / Right | Walk |
| `Space` | Jump |
| `Enter` | Start |
| `Esc` | Quit |

## Structure

- `mario/main.lua` — window, virtual resolution (256×144) and state machine setup
- `mario/src/states/` — `game` (`start`, `play`) and `entity` (player and snail behavior states)
- `mario/src/LevelMaker.lua`, `Tile.lua`, `TileMap.lua`, `GameObject.lua` — level generation, tiles and blocks
- `mario/lib/` — [push](https://github.com/Ulydev/push), [knife](https://github.com/airstruck/knife) (timers/tweens) and `class.lua`
- `character-*`, `level-*`, `tiles-*` — step-by-step lecture snapshots
