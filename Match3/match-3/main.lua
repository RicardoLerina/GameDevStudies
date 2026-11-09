-- Match 3: entry point. Sets up the window, the virtual resolution and the
-- global state machine, then forwards LÖVE callbacks to the active state.

-- Nearest-neighbour filtering keeps the pixel art crisp when upscaled.
love.graphics.setDefaultFilter('nearest', 'nearest')

require 'src.Dependencies'

-- Real window size.
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- Internal resolution the game is drawn at before push scales it up.
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

-- Pixels per second the background image scrolls to the left.
BACKGROUND_SCROLL_SPEED = 80

function love.load()
    love.window.setTitle('Match 3')

    math.randomseed(os.time())

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = 'normal' })

    gSounds['music']:setLooping(true)
    gSounds['music']:play()

    -- Each entry is a factory so every state change builds a fresh instance.
    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['begin-game'] = function() return BeginGameState() end,
        ['play'] = function() return PlayState() end,
        ['game-over'] = function() return GameOverState() end
    }
    gStateMachine:change('start')

    backgroundX = 0

    -- Keys pressed during the current frame; cleared at the end of update.
    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push.resize(w, h)
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

-- True only on the frame the key went down, unlike love.keyboard.isDown.
function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function love.update(dt)
    backgroundX = backgroundX - BACKGROUND_SCROLL_SPEED * dt

    -- Wrap the background back to the start once the repeating section
    -- has scrolled past, giving the illusion of an endless image.
    if backgroundX <= -1024 + VIRTUAL_WIDTH - 4 + 51 then
        backgroundX = 0
    end

    gStateMachine:update(dt)

    love.keyboard.keysPressed = {}
end

function love.draw()
    push.start()

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gTextures['background'], backgroundX, 0)

    gStateMachine:render()

    push.finish()
end
