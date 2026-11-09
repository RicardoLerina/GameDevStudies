Brick = Class{}

-- RGB values matching each brick color in the sprite sheet, used to tint the
-- particles when a brick is hit.
paletteColors = {
    -- blue
    [1] = {
        ['r'] = 99,
        ['g'] = 155,
        ['b'] = 255
    },
    -- green
    [2] = {
        ['r'] = 106,
        ['g'] = 190,
        ['b'] = 47
    },
    -- red
    [3] = {
        ['r'] = 217,
        ['g'] = 87,
        ['b'] = 99
    },
    -- purple
    [4] = {
        ['r'] = 215,
        ['g'] = 123,
        ['b'] = 186
    },
    -- gold
    [5] = {
        ['r'] = 251,
        ['g'] = 242,
        ['b'] = 54
    }
}

function Brick:init(x, y)
    -- Color (1-5) and tier (0-3) together decide the sprite, the score value
    -- and how many hits the brick takes.
    self.tier = 0
    self.color = 1

    self.x = x
    self.y = y
    self.width = 32
    self.height = 16

    -- Broken bricks stay in the table but are skipped for collision and drawing.
    self.inPlay = true

    self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 64)

    self.psystem:setParticleLifetime(0.5, 1)

    -- Mostly downward acceleration with a little horizontal spread, so the
    -- debris looks like it is falling.
    self.psystem:setLinearAcceleration(-15, 0, 15, 80)

    -- A normal distribution clusters particles near the center, which looks
    -- more natural than a uniform spread.
    self.psystem:setEmissionArea('normal', 10, 10)
end

function Brick:hit()
    -- Particles take the brick's color and fade from an alpha that is
    -- stronger on higher tiers down to fully transparent.
    self.psystem:setColors(
        paletteColors[self.color].r / 255,
        paletteColors[self.color].g / 255,
        paletteColors[self.color].b / 255,
        55 * (self.tier + 1) / 255,
        paletteColors[self.color].r / 255,
        paletteColors[self.color].g / 255,
        paletteColors[self.color].b / 255,
        0
    )
    self.psystem:emit(64)

    -- Stopping first restarts the sound, so quick consecutive hits are all heard.
    gSounds['brick-hit-2']:stop()
    gSounds['brick-hit-2']:play()

    -- Each hit drops the color by one. Below the first color, the brick wraps
    -- to the last color of the tier below, or breaks if it is already tier 0.
    if self.tier > 0 then
        if self.color == 1 then
            self.tier = self.tier - 1
            self.color = 5
        else
            self.color = self.color - 1
        end
    else
        if self.color == 1 then
            self.inPlay = false
        else
            self.color = self.color - 1
        end
    end

    if not self.inPlay then
        gSounds['brick-hit-1']:stop()
        gSounds['brick-hit-1']:play()
    end
end

function Brick:update(dt)
    self.psystem:update(dt)
end

function Brick:render()
    if self.inPlay then
        love.graphics.draw(gTextures['main'],
            -- The sheet groups the 4 tiers of each color together, so the
            -- color picks the group and the tier picks the sprite inside it.
            gFrames['bricks'][1 + ((self.color - 1) * 4) + self.tier],
            self.x, self.y)
    end
end

-- Separate from render so PlayState can draw all particles after all bricks;
-- otherwise later bricks would cover the particles of earlier ones.
function Brick:renderParticles()
    love.graphics.draw(self.psystem, self.x + 16, self.y + 8)
end
