-- Tile: a single gem on the board. It knows its cell in the grid (gridX,
-- gridY) and its pixel offset inside the board (x, y), which is what gets
-- tweened when tiles swap or fall.

Tile = Class{}

-- x, y: grid cell (1-8). color: 1-18. variety: 1-6 (the shape/pattern).
function Tile:init(x, y, color, variety)
    self.gridX = x
    self.gridY = y

    -- Each cell is 32x32 pixels.
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    self.color = color
    self.variety = variety
end

-- x, y: board origin on screen, added to the tile's own offset.
function Tile:render(x, y)
    -- Dark copy drawn slightly down-right acts as a drop shadow.
    love.graphics.setColor(34/255, 32/255, 52/255, 255/255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)
end
