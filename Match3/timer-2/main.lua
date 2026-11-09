-- timer-2: the same counters as timer-1, written with Timer.every.

push = require 'push'
Timer = require 'knife.timer'

-- Resolution the scene is drawn at before being scaled to the window.
VIRTUAL_WIDTH = 384
VIRTUAL_HEIGHT = 216

-- Real window size.
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

function love.load()

    -- Seconds between ticks for each counter.
    intervals = {1, 2, 4, 3, 2, 8}

    counters = {0, 0, 0, 0, 0, 0}

    -- One repeating timer per counter.
    for i = 1, 6 do

        Timer.every(intervals[i], function()
            counters[i] = counters[i] + 1
        end)
    end

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

    -- Drives every timer registered above.
    Timer.update(dt)
end

function love.draw()
    push.start()

    for i = 1, 6 do

        love.graphics.printf('Timer: ' .. tostring(counters[i]) .. ' seconds (every ' ..
            tostring(intervals[i]) .. ')', 0, 54 + i * 16, VIRTUAL_WIDTH, 'center')
    end

    push.finish()
end
