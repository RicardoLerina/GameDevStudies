Entity = Class{}

-- copies the definition values into a new entity
function Entity:init(def)

    self.direction = 'down'

    self.animations = self:createAnimations(def.animations)

    self.x = def.x
    self.y = def.y
    self.width = def.width
    self.height = def.height

    self.offsetX = def.offsetX or 0
    self.offsetY = def.offsetY or 0

    self.walkSpeed = def.walkSpeed

    self.health = def.health

    self.invulnerable = false
    self.invulnerableDuration = 0
    self.invulnerableTimer = 0

    self.flashTimer = 0

    self.dead = false
end

-- turns animation definitions into Animation objects
function Entity:createAnimations(animations)
    local animationsReturned = {}

    for k, animationDef in pairs(animations) do
        animationsReturned[k] = Animation {
            texture = animationDef.texture or 'entities',
            frames = animationDef.frames,
            interval = animationDef.interval
        }
    end

    return animationsReturned
end

-- AABB overlap test between this entity and a target
function Entity:collides(target)
    return not (self.x + self.width < target.x or self.x > target.x + target.width or
                self.y + self.height < target.y or self.y > target.y + target.height)
end

-- subtracts health from the entity
function Entity:damage(dmg)
    self.health = self.health - dmg
end

-- grants temporary invulnerability after a hit
function Entity:goInvulnerable(duration)
    self.invulnerable = true
    self.invulnerableDuration = duration
end

-- moves the entity to another state in its state machine
function Entity:changeState(name)
    self.stateMachine:change(name)
end

-- switches to the named animation
function Entity:changeAnimation(name)
    self.currentAnimation = self.animations[name]
end

-- ticks invulnerability and the state machine
function Entity:update(dt)
    if self.invulnerable then
        self.flashTimer = self.flashTimer + dt
        self.invulnerableTimer = self.invulnerableTimer + dt

        if self.invulnerableTimer > self.invulnerableDuration then
            self.invulnerable = false
            self.invulnerableTimer = 0
            self.invulnerableDuration = 0
            self.flashTimer = 0
        end
    end

    self.stateMachine:update(dt)

    if self.currentAnimation then
        self.currentAnimation:update(dt)
    end
end

-- delegates AI decisions to the current state
function Entity:processAI(params, dt)
    self.stateMachine:processAI(params, dt)
end

-- draws the entity, flashing while invulnerable
function Entity:render(adjacentOffsetX, adjacentOffsetY)

    if self.invulnerable and self.flashTimer > 0.06 then
        self.flashTimer = 0
        love.graphics.setColor(1, 1, 1, 64/255)
    end

    self.x, self.y = self.x + (adjacentOffsetX or 0), self.y + (adjacentOffsetY or 0)
    self.stateMachine:render()
    love.graphics.setColor(1, 1, 1, 1)
    self.x, self.y = self.x - (adjacentOffsetX or 0), self.y - (adjacentOffsetY or 0)
end
