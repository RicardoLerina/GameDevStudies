-- tween-0: moves a sprite across the screen by interpolating its x
-- position over a fixed duration.

push = require 'push'

-- Resolution the scene is drawn at before being scaled to the window.
VIRTUAL_WIDTH = 384
VIRTUAL_HEIGHT = 216

-- Real window size.
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- Seconds the trip takes.
MOVE_DURATION = 2

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    flappySprite = love.graphics.newImage('flappy.png')

    flappyX, flappyY = 0, VIRTUAL_HEIGHT / 2 - 8

    timer = 0

    -- Final x so the sprite stops touching the right edge.
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
    if timer < MOVE_DURATION then
        timer = timer + dt

        -- Fraction of the duration elapsed times the distance; clamped so
        -- it never overshoots.
        flappyX = math.min(endX, endX * (timer / MOVE_DURATION))
    end
end

function love.draw()
    push.start()
    love.graphics.draw(flappySprite, flappyX, flappyY)
    -- Show elapsed time for reference.
    love.graphics.print(tostring(timer), 4, 4)
    push.finish()
end
