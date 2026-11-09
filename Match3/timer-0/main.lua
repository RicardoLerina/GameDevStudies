-- timer-0: counts seconds by accumulating dt by hand.

push = require 'push'

-- Resolution the scene is drawn at before being scaled to the window.
VIRTUAL_WIDTH = 384
VIRTUAL_HEIGHT = 216

-- Real window size.
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

function love.load()
    -- Seconds counted so far and time accumulated toward the next one.
    currentSecond = 0
    secondTimer = 0

    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setMode(1280, 720, {
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
    secondTimer = secondTimer + dt

    if secondTimer > 1 then
        currentSecond = currentSecond + 1
        -- Keep the leftover fraction so no time is lost between seconds.
        secondTimer = secondTimer % 1
    end
end

function love.draw()
    push.start()
    love.graphics.printf('Timer: ' .. tostring(currentSecond) .. ' seconds',
        0, VIRTUAL_HEIGHT / 2 - 6, VIRTUAL_WIDTH, 'center')
    push.finish()
end
