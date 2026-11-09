-- timer-1: five manual counters with different intervals. Shows how
-- quickly this approach gets repetitive without a timer library.

push = require 'push'

-- Resolution the scene is drawn at before being scaled to the window.
VIRTUAL_WIDTH = 384
VIRTUAL_HEIGHT = 216

-- Real window size.
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

function love.load()
    -- One counter/accumulator pair per interval.
    currentSecond = 0
    secondTimer = 0
    currentSecond2 = 0
    secondTimer2 = 0
    currentSecond3 = 0
    secondTimer3 = 0
    currentSecond4 = 0
    secondTimer4 = 0
    currentSecond5 = 0
    secondTimer5 = 0

    love.graphics.setDefaultFilter('nearest', 'nearest')

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
    -- Every block below is the same logic with a different interval;
    -- the modulo keeps the leftover time.
    secondTimer = secondTimer + dt

    if secondTimer > 1 then
        currentSecond = currentSecond + 1
        secondTimer = secondTimer % 1
    end

    secondTimer2 = secondTimer2 + dt

    if secondTimer2 > 2 then
        currentSecond2 = currentSecond2 + 1
        secondTimer2 = secondTimer2 % 2
    end

    secondTimer3 = secondTimer3 + dt

    if secondTimer3 > 4 then
        currentSecond3 = currentSecond3 + 1
        secondTimer3 = secondTimer3 % 4
    end

    secondTimer4 = secondTimer4 + dt

    if secondTimer4 > 3 then
        currentSecond4 = currentSecond4 + 1
        secondTimer4 = secondTimer4 % 3
    end

    secondTimer5 = secondTimer5 + dt

    if secondTimer5 > 2 then
        currentSecond5 = currentSecond5 + 1
        secondTimer5 = secondTimer5 % 2
    end
end

function love.draw()
    push.start()
    love.graphics.printf('Timer: ' .. tostring(currentSecond) .. ' seconds (every 1)',
        0, 68, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Timer: ' .. tostring(currentSecond2) .. ' seconds (every 2)',
        0, 82, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Timer: ' .. tostring(currentSecond3) .. ' seconds (every 4)',
        0, 96, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Timer: ' .. tostring(currentSecond4) .. ' seconds (every 3)',
        0, 110, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Timer: ' .. tostring(currentSecond5) .. ' seconds (every 2)',
        0, 124, VIRTUAL_WIDTH, 'center')
    push.finish()
end
