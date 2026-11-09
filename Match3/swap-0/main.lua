-- swap-0: generates and draws an 8x8 board of random tiles.

push = require 'push'

-- Quad helpers (GenerateQuads, GenerateTileQuads).
require 'Util'

-- Resolution the scene is drawn at before being scaled to the window.
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

-- Real window size.
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    tileSprite = love.graphics.newImage('match3.png')

    -- Every 32x32 tile in the sheet, as a flat list.
    tileQuads = GenerateQuads(tileSprite, 32, 32)

    board = generateBoard()

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

function love.draw()
    push.start()

    drawBoard(128, 16)

    push.finish()
end

-- Builds board[y][x], each cell holding its pixel position and a
-- random tile index.
function generateBoard()
    local tiles = {}

    for y = 1, 8 do

        table.insert(tiles, {})

        for x = 1, 8 do

            table.insert(tiles[y], {

                x = (x - 1) * 32,
                y = (y - 1) * 32,

                tile = math.random(#tileQuads)
            })
        end
    end

    return tiles
end

-- Draws every tile offset by the board position on screen.
function drawBoard(offsetX, offsetY)

    for y = 1, 8 do

        for x = 1, 8 do
            local tile = board[y][x]

            love.graphics.draw(tileSprite, tileQuads[tile.tile],
                tile.x + offsetX, tile.y + offsetY)
        end
    end
end
