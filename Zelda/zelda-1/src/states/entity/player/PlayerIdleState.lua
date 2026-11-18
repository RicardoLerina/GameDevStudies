PlayerIdleState = Class{__includes = EntityIdleState}

-- resets the sword hitbox when idling
function PlayerIdleState:enter(params)

    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

-- switches to walk or swing on input
function PlayerIdleState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('walk')
    end
end
