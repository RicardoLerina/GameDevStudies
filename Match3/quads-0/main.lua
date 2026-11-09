-- quads-0: draws the whole sprite sheet as a single image.

function love.load()
    push = require 'push'

    -- Keep pixel art sharp when scaled up.
    love.graphics.setDefaultFilter('nearest', 'nearest')

    texture = love.graphics.newImage('match3.png')

    love.window.setMode(1280, 720, {
        fullscreen = false,
        vsync = true
    })

    push.setupScreen(512, 288, { upscale = 'normal' })
end

-- Escape closes the program.
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end

function love.draw()
    push.start()
    love.graphics.draw(texture)
    push.finish()
end
