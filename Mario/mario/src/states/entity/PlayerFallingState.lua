-- PlayerFallingState: gravity-driven descent. Lands on ground or blocks and
-- stomps snails.

PlayerFallingState = Class{__includes = BaseState}

function PlayerFallingState:init(player, gravity)
    self.player = player
    self.gravity = gravity
    self.animation = Animation {
        frames = {3},
        interval = 1
    }
    self.player.currentAnimation = self.animation
end

function PlayerFallingState:update(dt)
    self.player.currentAnimation:update(dt)
    self.player.dy = self.player.dy + self.gravity * dt
    self.player.y = self.player.y + (self.player.dy * dt)

    -- Check the tiles under the feet to land.
    local tileBottomLeft = self.player.map:pointToTile(self.player.x + 1, self.player.y + self.player.height)
    local tileBottomRight = self.player.map:pointToTile(self.player.x + self.player.width - 1, self.player.y + self.player.height)

    if (tileBottomLeft and tileBottomRight) and (tileBottomLeft:collidable() or tileBottomRight:collidable()) then
        self.player.dy = 0

        if love.keyboard.isDown('left') or love.keyboard.isDown('right') then
            self.player:changeState('walking')
        else
            self.player:changeState('idle')
        end

        self.player.y = (tileBottomLeft.y - 1) * TILE_SIZE - self.player.height

    -- Falling out of the map ends the run.
    elseif self.player.y > VIRTUAL_HEIGHT then
        gSounds['death']:play()
        gStateMachine:change('start')

    elseif love.keyboard.isDown('left') then
        self.player.direction = 'left'
        self.player.x = self.player.x - PLAYER_WALK_SPEED * dt
        self.player:checkLeftCollisions(dt)
    elseif love.keyboard.isDown('right') then
        self.player.direction = 'right'
        self.player.x = self.player.x + PLAYER_WALK_SPEED * dt
        self.player:checkRightCollisions(dt)
    end

    -- Land on solid objects; collect consumable ones.
    for k, object in pairs(self.player.level.objects) do
        if object:collides(self.player) then
            if object.solid then
                self.player.dy = 0
                self.player.y = object.y - self.player.height

                if love.keyboard.isDown('left') or love.keyboard.isDown('right') then
                    self.player:changeState('walking')
                else
                    self.player:changeState('idle')
                end
            elseif object.consumable then
                object.onConsume(self.player)
                table.remove(self.player.level.objects, k)
            end
        end
    end

    -- Landing on a snail kills it and scores 100.
    for k, entity in pairs(self.player.level.entities) do
        if entity:collides(self.player) then
            gSounds['kill']:play()
            gSounds['kill2']:play()
            self.player.score = self.player.score + 100
            table.remove(self.player.level.entities, k)
        end
    end
end
