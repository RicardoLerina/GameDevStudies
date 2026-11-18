-- Estado parado do jogador: inicia a caminhada quando uma seta é pressionada.

-- Espera a entrada do jogador
PlayerIdleState = Class{__includes = EntityIdleState}

-- Define a direção pela seta pressionada e passa para 'walk'
function PlayerIdleState:update(dt)
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
    end
end
