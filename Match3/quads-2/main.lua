-- Splits a sprite sheet into equally sized quads, left to right and
-- top to bottom, and returns them as a flat list.
-- quads-2: cuts the whole sheet into quads and draws a random one each
-- frame (which makes it flicker on purpose).

function GenerateQuads(texture, width, height)
    local sheetWidth = texture:getWidth() / width
    local sheetHeight = texture:getHeight() / height

    local quadCounter = 1
    local quads = {}

    for y = 0, sheetHeight - 1 do
        for x = 0, sheetWidth - 1 do
            quads[quadCounter] =
                love.graphics.newQuad(x * width, y * height, width, height,
                    texture:getDimensions())
            quadCounter = quadCounter + 1
        end
    end

    return quads
end

function love.load()
    push = require 'push'

    love.graphics.setDefaultFilter('nearest', 'nearest')

    texture = love.graphics.newImage('match3.png')
    quads = GenerateQuads(texture, 32, 32)
    -- Picked once here, but draw() below chooses a new one every frame.
    randomQuad = quads[math.random(#quads)]

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
    love.graphics.draw(texture, quads[math.random(#quads)])
    push.finish()
end
