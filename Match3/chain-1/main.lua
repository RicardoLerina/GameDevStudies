-- chain-1: the same corner-to-corner trip as chain-0, but written as a
-- chain of Timer.tween calls, each one started by the previous finish.
-- Opacity is tweened too, so the sprite fades in and out.

push = require 'push'
Timer = require 'knife.timer'

-- Resolution the scene is drawn at before being scaled to the window.
VIRTUAL_WIDTH = 384
VIRTUAL_HEIGHT = 216

-- Real window size.
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- Seconds each leg of the trip takes.
MOVEMENT_TIME = 2

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    flappySprite = love.graphics.newImage('flappy.png')

    -- Every value the tweens will animate lives in this table.
    flappy = {x = 0, y = 0, opacity = 255}

    -- finish() schedules the next tween once the current one ends.
    Timer.tween(MOVEMENT_TIME, {
        [flappy] = {x = VIRTUAL_WIDTH - flappySprite:getWidth(), y = 0, opacity = 0}
    })
    :finish(function()
        Timer.tween(MOVEMENT_TIME, {
            [flappy] = {x = VIRTUAL_WIDTH - flappySprite:getWidth(), y = VIRTUAL_HEIGHT - flappySprite:getHeight(), opacity = 255}
        })
        :finish(function()
            Timer.tween(MOVEMENT_TIME, {
                [flappy] = {x = 0, y = VIRTUAL_HEIGHT - flappySprite:getHeight(), opacity = 0}
            })
            :finish(function()
                Timer.tween(MOVEMENT_TIME, {
                    [flappy] = {x = 0, y = 0, opacity = 255}
                })
            end)
        end)
    end)

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
    -- Advances every active tween.
    Timer.update(dt)
end

function love.draw()
    push.start()
    -- Opacity is stored as 0-255; LÖVE expects 0-1.
    love.graphics.setColor(1, 1, 1, flappy.opacity / 255)
    love.graphics.draw(flappySprite, flappy.x, flappy.y)
    push.finish()
end
