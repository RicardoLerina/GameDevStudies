-- quads-1: draws only one 32x32 region of the sprite sheet using a quad.

function love.load()
    push = require 'push'

    -- Keep pixel art sharp when scaled up.
    love.graphics.setDefaultFilter('nearest', 'nearest')

    texture = love.graphics.newImage('match3.png')
    -- A quad is a rectangle inside a texture; this one is the top-left tile.
    quad = love.graphics.newQuad(0, 0, 32, 32, texture:getDimensions())

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
    love.graphics.draw(texture, quad)
    push.finish()
end
