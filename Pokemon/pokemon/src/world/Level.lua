-- Fase do jogo: duas camadas de tiles (grama base e grama alta) e o jogador.

-- Mapa 50x50 com o jogador
Level = Class{}

-- Cria as camadas, o jogador e sua máquina de estados
function Level:init()
    self.tileWidth = 50
    self.tileHeight = 50

    self.baseLayer = TileMap(self.tileWidth, self.tileHeight)
    self.grassLayer = TileMap(self.tileWidth, self.tileHeight)
    self:createMaps()
    -- Jogador começa no tile (10, 10)
    self.player = Player {
        animations = ENTITY_DEFS['player'].animations,
        mapX = 10,
        mapY = 10,
        width = 16,
        height = 16,
    }
    -- Estados do jogador: andar e ficar parado
    self.player.stateMachine = StateMachine {
        ['walk'] = function() return PlayerWalkState(self.player, self) end,
        ['idle'] = function() return PlayerIdleState(self.player) end
    }
    self.player.stateMachine:change('idle')
end

-- Preenche a camada base com grama aleatória e a de grama alta abaixo da linha 10
function Level:createMaps()
    for y = 1, self.tileHeight do
        table.insert(self.baseLayer.tiles, {})

        for x = 1, self.tileWidth do
            local id = TILE_IDS['grass'][math.random(#TILE_IDS['grass'])]
            table.insert(self.baseLayer.tiles[y], Tile(x, y, id))
        end
    end
    for y = 1, self.tileHeight do
        table.insert(self.grassLayer.tiles, {})
        for x = 1, self.tileWidth do
            local id = y > 10 and TILE_IDS['tall-grass'] or TILE_IDS['empty']
            table.insert(self.grassLayer.tiles[y], Tile(x, y, id))
        end
    end
end

-- Atualiza o jogador
function Level:update(dt)
    self.player:update(dt)
end

-- Desenha as camadas e o jogador por cima
function Level:render()
    self.baseLayer:render()
    self.grassLayer:render()
    self.player:render()
end
