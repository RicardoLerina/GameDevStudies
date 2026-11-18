love.graphics.setDefaultFilter('nearest', 'nearest')
require 'src.Dependencies'

local paused = false

-- loads assets and sets up the window and state machine
function love.load()
    love.setDeprecationOutput(false)
    math.randomseed(os.time())
    love.window.setTitle('Legend of Zelda')

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = 'normal' })

    love.graphics.setFont(gFonts['small'])

    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['play'] = function() return PlayState() end,
        ['game-over'] = function() return GameOverState() end
    }
    gStateMachine:change('start')

    gSounds['music']:setLooping(true)
    gSounds['music']:play()

    love.keyboard.keysPressed = {}
end

-- keeps the virtual resolution on window resize
function love.resize(w, h)
    push.resize(w, h)
end

-- records key presses and handles quitting
function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

-- true if the key was pressed this frame
function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

-- updates the state machine and clears the key buffer
function love.update(dt)
    if love.keyboard.wasPressed('p') then
        paused = not paused
    end

    if not paused then
        Timer.update(dt)
        gStateMachine:update(dt)
    end

    love.keyboard.keysPressed = {}
end

-- draws the current state at virtual resolution
function love.draw()
    push.start()
    gStateMachine:render()
    push.finish()
end
