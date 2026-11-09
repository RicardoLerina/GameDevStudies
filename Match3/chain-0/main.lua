-- chain-0: moves a sprite around the four corners of the screen one
-- after another, using a manual timer and a list of destinations.

push = require 'push'

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

    -- Current position of the sprite.
    flappyX, flappyY = 0, 0

    -- Where the current leg started; interpolation goes from here.
    baseX, baseY = flappyX, flappyY

    timer = 0

    -- Corners to visit in order: top-right, bottom-right, bottom-left, top-left.
    destinations = {
        [1] = {x = VIRTUAL_WIDTH - flappySprite:getWidth(), y = 0},
        [2] = {x = VIRTUAL_WIDTH - flappySprite:getWidth(), y = VIRTUAL_HEIGHT - flappySprite:getHeight()},
        [3] = {x = 0, y = VIRTUAL_HEIGHT - flappySprite:getHeight()},
        [4] = {x = 0, y = 0}
    }

    for k, destination in pairs(destinations) do
        destination.reached = false
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
    -- Clamp so the last frame lands exactly on the destination.
    timer = math.min(MOVEMENT_TIME, timer + dt)

    -- Only the first destination not yet reached is animated each frame.
    for i, destination in ipairs(destinations) do
        if not destination.reached then
            flappyX, flappyY =

                baseX + (destination.x - baseX) * timer / MOVEMENT_TIME,
                baseY + (destination.y - baseY) * timer / MOVEMENT_TIME

            -- Leg finished: mark it and start the next one from here.
            if timer == MOVEMENT_TIME then
                destination.reached = true
                baseX, baseY = destination.x, destination.y
                timer = 0
            end

            break
        end
    end
end

function love.draw()
    push.start()
    love.graphics.draw(flappySprite, flappyX, flappyY)
    push.finish()
end
