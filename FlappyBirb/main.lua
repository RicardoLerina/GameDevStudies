push = require 'push'
Class = require 'class'

require 'StateMachine'

require 'states.BaseState'
require 'states.CountdownState'
require 'states.PlayState'
require 'states.ScoreState'
require 'states.TitleScreenState'

require 'Bird'
require 'Pipe'
require 'PipePair'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- The game is drawn at this low resolution and push scales it up to the window.
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

local backgroundScroll = 0
local groundScroll = 0

-- The ground scrolls faster than the background to create a parallax effect.
local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60

-- Point in the background image where it repeats itself, so resetting the
-- scroll offset here produces a seamless loop.
local BACKGROUND_LOOPING_POINT = 413

-- Global flag so PlayState can freeze the world when the bird dies.
scrolling = true

function love.load()
    -- Nearest-neighbor filtering keeps pixel art sharp when scaled.
    love.graphics.setDefaultFilter('nearest', 'nearest')

    math.randomseed(os.time())

    love.window.setTitle('Fifty Bird')

    smallFont = love.graphics.newFont('font.ttf', 8)
    mediumFont = love.graphics.newFont('flappy.ttf', 14)
    flappyFont = love.graphics.newFont('flappy.ttf', 28)
    hugeFont = love.graphics.newFont('flappy.ttf', 56)
    love.graphics.setFont(flappyFont)

    -- Assets are loaded once here and shared globally, instead of each object
    -- loading its own copy.
    gTextures = {
        ['background'] = love.graphics.newImage('background.png'),
        ['ground'] = love.graphics.newImage('ground.png'),
        ['bird'] = love.graphics.newImage('bird.png'),
        ['pipe'] = love.graphics.newImage('pipe.png')
    }

    gSounds = {
        ['jump'] = love.audio.newSource('jump.wav', 'static'),
        ['explosion'] = love.audio.newSource('explosion.wav', 'static'),
        ['hurt'] = love.audio.newSource('hurt.wav', 'static'),
        ['score'] = love.audio.newSource('score.wav', 'static'),
        ['music'] = love.audio.newSource('marios_way.mp3', 'static')
    }

    gSounds['music']:setLooping(true)
    gSounds['music']:play()

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = true,
        resizable = true
    })

    push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = 'normal' })

    -- Each entry is a factory function, so every state change builds a fresh
    -- state object (e.g. a new PlayState starts with score 0 and no pipes).
    gStateMachine = StateMachine {
        ['title'] = function() return TitleScreenState() end,
        ['countdown'] = function() return CountdownState() end,
        ['play'] = function() return PlayState() end,
        ['score'] = function() return ScoreState() end
    }
    gStateMachine:change('title')

    -- Per-frame input buffers, filled by the callbacks below and cleared at
    -- the end of every love.update.
    love.keyboard.keysPressed = {}
    love.mouse.buttonsPressed = {}
end

function love.resize(w, h)
    push.resize(w, h)
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true

    if key == 'escape' then
        love.event.quit()
    end
end

function love.mousepressed(x, y, button)
    love.mouse.buttonsPressed[button] = true
end

-- LÖVE only offers isDown (held keys). These helpers answer "was this pressed
-- during the current frame?", which is what a single flap needs.
function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.mouse.wasPressed(button)
    return love.mouse.buttonsPressed[button]
end

function love.update(dt)
    if scrolling then
        -- The modulo wraps the offset back to 0 once an image has scrolled a
        -- full loop, so the texture appears to scroll forever.
        backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT
        groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % VIRTUAL_WIDTH
    end

    gStateMachine:update(dt)

    love.keyboard.keysPressed = {}
    love.mouse.buttonsPressed = {}
end

function love.draw()
    push.start()

    -- Draw order matters: background, then the current state (pipes, bird,
    -- text), then the ground on top so pipes appear to come out of it.
    love.graphics.draw(gTextures['background'], -backgroundScroll, 0)
    gStateMachine:render()
    love.graphics.draw(gTextures['ground'], -groundScroll, VIRTUAL_HEIGHT - 16)

    push.finish()
end
