# GameDevStudies

A personal repository for learning game development. The projects follow the structure of Harvard's [CS50's Introduction to Game Development](https://cs50.harvard.edu/games/) (CS50 2D) and are written in [Lua](https://www.lua.org/) on top of the [LÖVE](https://love2d.org/) framework.

## Flappy Bird ("Fifty Bird")

A Flappy Bird remake with a scrolling parallax background, randomly generated pipes, sound effects, background music and mouse or keyboard controls.

### Features

- **Virtual resolution:** the game renders at 512×288 and scales to the screen (fullscreen and resizable) without blur, using [push](https://github.com/Ulydev/push) and nearest-neighbor filtering.
- **State machine:** `title` → `countdown` → `play` → `score`, with each state in its own class under `states/`.
- **Parallax scrolling:** the background and ground loop forever at different speeds and freeze when the bird dies.
- **Procedural pipes:** a new pipe pair spawns every 2 seconds. Each gap is placed at most 20 pixels above or below the previous one, so the course stays playable.
- **Bird physics:** gravity pulls the bird down, and each flap sets its upward speed to a fixed value.
- **Lenient collision:** AABB collision with a hitbox 2 pixels smaller on each side than the sprite.
- **Scoring:** one point per pipe pair passed.
- **Audio:** sound effects for flapping, scoring and crashing, plus looping background music.

### Controls

| Key | Action |
| --- | --- |
| `Space` / left mouse button | Flap |
| `Enter` | Start the game, or play again after losing |
| `Esc` | Quit |

### Running the game

1. Install [LÖVE 11.x](https://love2d.org/).
2. From the repository root, run:

   ```sh
   love FlappyBirb
   ```

   On Windows you can also drag the `FlappyBirb` folder onto `love.exe`.

### Code structure

```
FlappyBirb/
├── main.lua              # Entry point: LÖVE callbacks, asset loading, input buffers, scrolling
├── StateMachine.lua      # Switches between game states and forwards update/render to the current one
├── Bird.lua              # Bird class: gravity, flapping, AABB collision, drawing
├── Pipe.lua              # Pipe class: a single pipe, mirrored when it hangs from the top
├── PipePair.lua          # PipePair class: an upper and lower pipe with a gap, moved together
├── states/
│   ├── BaseState.lua         # Empty base class every state inherits from
│   ├── TitleScreenState.lua  # Title screen
│   ├── CountdownState.lua    # 3-2-1 countdown before each run
│   ├── PlayState.lua         # Main gameplay: pipe spawning, scoring, collisions
│   └── ScoreState.lua        # Game-over screen showing the final score
├── class.lua             # hump.class, a small OOP library for Lua
├── push.lua              # push, a resolution-handling library
├── *.png                 # bird, pipe, background and ground sprites
├── *.ttf                 # font.ttf and flappy.ttf
└── *.wav, *.mp3          # Sound effects and background music
```

---

## Credits

- Game design and base code from **CS50's Introduction to Game Development**, by Colton Ogden (Harvard University).
- Background music: ["Mario's Way" by xsgianni](https://freesound.org/people/xsgianni/sounds/388079/), via Freesound.
- [`push.lua`](push.lua) by Ulysse Ramage, MIT License.
- [`class.lua`](class.lua) (hump.class) by Matthias Richter, MIT-style license.

This repository is for educational purposes.
