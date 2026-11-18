-- Estado de caminhada: move a entidade um tile por vez usando tweens,
-- respeitando os limites do mapa.

-- Entidade andando entre tiles
EntityWalkState = Class{__includes = EntityBaseState}

-- Guarda a entidade e a fase
function EntityWalkState:init(entity, level)
    self.entity = entity
    self.level = level

    self.canWalk = false
end

-- Ao entrar, tenta dar um passo
function EntityWalkState:enter(params)
    self:attemptMove()
end

-- Calcula o tile de destino e anima o deslocamento até ele
function EntityWalkState:attemptMove()
    self.entity:changeAnimation('walk-' .. tostring(self.entity.direction))
    -- Tile de destino conforme a direção
    local toX, toY = self.entity.mapX, self.entity.mapY
    if self.entity.direction == 'left' then
        toX = toX - 1
    elseif self.entity.direction == 'right' then
        toX = toX + 1
    elseif self.entity.direction == 'up' then
        toY = toY - 1
    else
        toY = toY + 1
    end
    -- Fora do mapa: volta a ficar parado
    if toX < 1 or toX > 24 or toY < 1 or toY > 13 then
        self.entity:changeState('idle')
        self.entity:changeAnimation('idle-' .. tostring(self.entity.direction))
        return
    end
    -- Atualiza a posição lógica imediatamente; o tween move só o desenho
    self.entity.mapY = toY
    self.entity.mapX = toX
    -- Desliza a sprite até o novo tile em meio segundo
    Timer.tween(0.5, {
        [self.entity] = {x = (toX - 1) * TILE_SIZE, y = (toY - 1) * TILE_SIZE - self.entity.height / 2}
    }):finish(function()
        -- Ao terminar, continua andando se houver uma seta pressionada; senão para
        if love.keyboard.isDown('left') then
            self.entity.direction = 'left'
            self.entity:changeState('walk')
        elseif love.keyboard.isDown('right') then
            self.entity.direction = 'right'
            self.entity:changeState('walk')
        elseif love.keyboard.isDown('up') then
            self.entity.direction = 'up'
            self.entity:changeState('walk')
        elseif love.keyboard.isDown('down') then
            self.entity.direction = 'down'
            self.entity:changeState('walk')
        else
            self.entity:changeState('idle')
        end
    end)
end
