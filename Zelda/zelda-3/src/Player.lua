Player = Class{__includes = Entity}

-- creates the player entity
function Player:init(def)
    Entity.init(self, def)
end

-- updates the player entity
function Player:update(dt)
    Entity.update(self, dt)
end

-- collision check that uses the player hitbox
function Player:collides(target)
    local selfY, selfHeight = self.y + self.height / 2, self.height - self.height / 2

    return not (self.x + self.width < target.x or self.x > target.x + target.width or
                selfY + selfHeight < target.y or selfY > target.y + target.height)
end

-- draws the player
function Player:render()
    Entity.render(self)

end
