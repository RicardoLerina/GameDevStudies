Bird = Class{}

-- Downward acceleration in pixels per second squared.
local GRAVITY = 980

function Bird:init()
    self.image = gTextures['bird']
    self.x = VIRTUAL_WIDTH / 2 - 8
    self.y = VIRTUAL_HEIGHT / 2 - 8

    self.width = self.image:getWidth()
    self.height = self.image:getHeight()

    self.dy = 0
end

-- AABB collision against a single pipe. The hitbox is shrunk by 2 pixels on
-- each side, so grazing a pipe by a pixel doesn't end the run.
function Bird:collides(pipe)
    if (self.x + 2) + (self.width - 4) >= pipe.x and self.x + 2 <= pipe.x + PIPE_WIDTH then
        if (self.y + 2) + (self.height - 4) >= pipe.y and self.y + 2 <= pipe.y + PIPE_HEIGHT then
            return true
        end
    end

    return false
end

function Bird:update(dt)
    -- Gravity changes velocity, and velocity changes position.
    self.dy = self.dy + GRAVITY * dt

    -- A flap replaces the velocity instead of adding to it, so every flap
    -- feels the same however fast the bird is falling.
    if love.keyboard.wasPressed('space') or love.mouse.wasPressed(1) then
        self.dy = -300
        gSounds['jump']:play()
    end

    self.y = self.y + self.dy * dt
end

function Bird:render()
    love.graphics.draw(self.image, self.x, self.y)
end
