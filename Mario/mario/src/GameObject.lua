-- GameObject: a static item in the level such as a jump block, gem or bush.

GameObject = Class{}

function GameObject:init(def)
    self.x = def.x
    self.y = def.y
    self.texture = def.texture
    self.width = def.width
    self.height = def.height
    self.frame = def.frame
    self.solid = def.solid
    self.collidable = def.collidable
    self.consumable = def.consumable
    self.onCollide = def.onCollide
    self.onConsume = def.onConsume
    self.hit = def.hit
end

-- Pixels trimmed from each side of a solid block's hitbox. Vertical stays full
-- so standing on top of a block is stable.
SOLID_HITBOX_INSET = 3

function GameObject:hitboxX()
    local inset = self.solid and SOLID_HITBOX_INSET or 0
    return self.x + inset, self.x + self.width - inset
end

function GameObject:collides(target)
    local left, right = self:hitboxX()
    return not (target.x > right or left > target.x + target.width or
            target.y > self.y + self.height or self.y > target.y + target.height)
end

function GameObject:update(dt)

end

function GameObject:render()
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame], self.x, self.y)
end
