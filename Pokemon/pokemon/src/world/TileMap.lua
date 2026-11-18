-- Grade de tiles que forma uma camada do mapa.

-- Matriz de tiles
TileMap = Class{}

-- Cria a tabela vazia com as dimensões
function TileMap:init(width, height)
    self.tiles = {}
    self.width = width
    self.height = height
end

-- Desenha todos os tiles
function TileMap:render()
    for y = 1, self.height do
        for x = 1, self.width do
            self.tiles[y][x]:render()
        end
    end
end
