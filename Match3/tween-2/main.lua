-- tween-2: 1000 sprites crossing the screen and fading in, each with
-- its own Timer.tween.

push = require 'push'
Timer = require 'knife.timer'

-- Resolution the scene is drawn at before being scaled to the window.
VIRTUAL_WIDTH = 384
VIRTUAL_HEIGHT = 216

-- Real window size.
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- Upper bound for the random durations.
TIMER_MAX = 10

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    flappySprite = love.graphics.newImage('flappy.png')

    birds = {}

    -- rate: tween duration for this bird. opacity goes 0 -> 255.
    for i = 1, 1000 do
        table.insert(birds, {

            x = 0,

            y = math.random(VIRTUAL_HEIGHT - 24),

            rate = math.random() + math.random(TIMER_MAX - 1),

            opacity = 0
        })
    end

    endX = VIRTUAL_WIDTH - flappySprite:getWidth()

    -- One tween per bird animating both x and opacity.
    for k, bird in pairs(birds) do
        Timer.tween(bird.rate, {

            [bird] = { x = endX, opacity = 255 }
        })
    end

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = 'normal' })
end

-- Keep the virtual screen scaled correctly when the window changes size.
function love.resize(w, h)
    push.resize(w, h)
end

-- Escape closes the program.
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end

function love.update(dt)
    -- Advances all tweens.
    Timer.update(dt)
end

function love.draw()
    push.start()

    for k, bird in pairs(birds) do
        -- Opacity is stored as 0-255; LÖVE expects 0-1.
        love.graphics.setColor(1, 1, 1, bird.opacity/255)
        love.graphics.draw(flappySprite, bird.x, bird.y)
    end

    push.finish()
end
