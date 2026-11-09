-- swap-2: same as swap-1, but the swap is animated with a tween
-- instead of happening instantly.

push = require 'push'
Timer = require 'knife.timer'

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

    -- Whether a first tile has been picked, and where it is.
    highlightedTile = false
    highlightedX, highlightedY = 1, 1

    -- Tile under the cursor.
    selectedTile = board[1][1]

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

    local x, y = selectedTile.gridX, selectedTile.gridY

    -- Move the cursor, staying inside the board.
    if key == 'up' then
        if y > 1 then
            selectedTile = board[y - 1][x]
        end
    elseif key == 'down' then
        if y < 8 then
            selectedTile = board[y + 1][x]
        end
    elseif key == 'left' then
        if x > 1 then
            selectedTile = board[y][x - 1]
        end
    elseif key == 'right' then
        if x < 8 then
            selectedTile = board[y][x + 1]
        end
    end

    -- First Enter picks a tile; the second swaps it with the cursor tile.
    if key == 'enter' or key == 'return' then
        if not highlightedTile then
            highlightedTile = true
            highlightedX, highlightedY = selectedTile.gridX, selectedTile.gridY
        else

            local tile1 = selectedTile
            local tile2 = board[highlightedY][highlightedX]

            -- Remember tile2 before overwriting it.
            local tempX, tempY = tile2.x, tile2.y
            local tempgridX, tempgridY = tile2.gridX, tile2.gridY

            -- The grid swap is immediate; only the drawing is animated.
            local tempTile = tile1
            board[tile1.gridY][tile1.gridX] = tile2
            board[tile2.gridY][tile2.gridX] = tempTile

            -- Slide each tile to the other one's old position.
            Timer.tween(0.2, {
                [tile2] = {x = tile1.x, y = tile1.y},
                [tile1] = {x = tempX, y = tempY}
            })

            tile2.gridX, tile2.gridY = tile1.gridX, tile1.gridY
            tile1.gridX, tile1.gridY = tempgridX, tempgridY

            highlightedTile = false

            selectedTile = tile2
        end
    end
end

function love.update(dt)
    -- Advances the swap animation.
    Timer.update(dt)
end

function love.draw()
    push.start()

    drawBoard(128, 16)

    push.finish()
end

-- Builds board[y][x]; each cell also stores its grid coordinates so
-- a tile knows where it is after being swapped.
function generateBoard()
    local tiles = {}

    for y = 1, 8 do

        table.insert(tiles, {})

        for x = 1, 8 do

            table.insert(tiles[y], {

                x = (x - 1) * 32,
                y = (y - 1) * 32,

                gridX = x,
                gridY = y,

                tile = math.random(#tileQuads)
            })
        end
    end

    return tiles
end

-- Draws the tiles, the highlight on the picked tile and the cursor.
function drawBoard(offsetX, offsetY)

    for y = 1, 8 do

        for x = 1, 8 do
            local tile = board[y][x]

            love.graphics.draw(tileSprite, tileQuads[tile.tile],
                tile.x + offsetX, tile.y + offsetY)

            -- Translucent white box over the picked tile.
            if highlightedTile then
                if tile.gridX == highlightedX and tile.gridY == highlightedY then

                    love.graphics.setColor(1, 1, 1, 128/255)

                    love.graphics.rectangle('fill', tile.x + offsetX, tile.y + offsetY, 32, 32, 4)

                    love.graphics.setColor(1, 1, 1, 1)
                end
            end
        end
    end

    -- Red outline around the cursor tile.
    love.graphics.setColor(1, 0, 0, 234/255)

    love.graphics.setLineWidth(4)

    love.graphics.rectangle('line', selectedTile.x + offsetX, selectedTile.y + offsetY, 32, 32, 4)

    love.graphics.setColor(1, 1, 1, 1)
end
