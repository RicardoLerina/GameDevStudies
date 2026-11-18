-- Tile individual do mapa: posição em tiles e id do quad na sprite sheet.

-- Um quadrado do mapa
Tile = Class{}

-- Guarda posição e id
function Tile:init(x, y, id)
    self.x = x
    self.y = y
    self.id = id
end

-- Sem lógica
function Tile:update(dt)
end

-- Desenha o quad correspondente na posição em pixels
function Tile:render()
    love.graphics.draw(gTextures['tiles'], gFrames['tiles'][self.id],
        (self.x - 1) * TILE_SIZE, (self.y - 1) * TILE_SIZE)
end
