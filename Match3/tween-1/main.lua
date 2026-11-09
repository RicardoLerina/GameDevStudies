-- tween-1: 100 sprites crossing the screen, each at its own speed.

push = require 'push'

-- Resolution the scene is drawn at before being scaled to the window.
VIRTUAL_WIDTH = 384
VIRTUAL_HEIGHT = 216

-- Real window size.
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- How long the simulation runs.
TIMER_MAX = 10

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    flappySprite = love.graphics.newImage('flappy.png')

    birds = {}

    -- rate: seconds this bird takes to reach the right edge.
    for i = 1, 100 do
        table.insert(birds, {

            x = 0,

            y = math.random(VIRTUAL_HEIGHT - 24),

            rate = math.random() + math.random(TIMER_MAX - 1)
        })
    end

    timer = 0

    endX = VIRTUAL_WIDTH - flappySprite:getWidth()

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

    if timer < TIMER_MAX then

        timer = timer + dt

        for k, bird in pairs(birds) do

            -- Same interpolation as tween-0, using each bird's own duration.
            bird.x = math.min(endX, endX * (timer / bird.rate))
        end
    end
end

function love.draw()
    push.start()

    for k, bird in pairs(birds) do
        love.graphics.draw(flappySprite, bird.x, bird.y)
    end

    love.graphics.print(tostring(timer), 4, 4)
    -- Frame rate, to compare against tween-2.
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 4, VIRTUAL_HEIGHT - 16)
    push.finish()
end
