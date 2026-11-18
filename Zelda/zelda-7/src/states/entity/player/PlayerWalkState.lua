PlayerWalkState = Class{__includes = EntityWalkState}

-- stores the player and starts the walk animation
function PlayerWalkState:init(player, dungeon)
    self.entity = player
    self.dungeon = dungeon

    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

-- reads input, moves the player and handles doorways
function PlayerWalkState:update(dt)
    if love.keyboard.isDown('left') then
        self.entity.direction = 'left'
        self.entity:changeAnimation('walk-left')
    elseif love.keyboard.isDown('right') then
        self.entity.direction = 'right'
        self.entity:changeAnimation('walk-right')
    elseif love.keyboard.isDown('up') then
        self.entity.direction = 'up'
        self.entity:changeAnimation('walk-up')
    elseif love.keyboard.isDown('down') then
        self.entity.direction = 'down'
        self.entity:changeAnimation('walk-down')
    else
        self.entity:changeState('idle')
    end

    if love.keyboard.wasPressed('space') then
        self.entity:changeState('swing-sword')
    end

    EntityWalkState.update(self, dt)

    if self.bumped then
        if self.entity.direction == 'left' then

            self.entity.x = self.entity.x - PLAYER_WALK_SPEED * dt

            for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
                if self.entity:collides(doorway) and doorway.open then

                    self.entity.y = doorway.y + 4
                    Event.dispatch('shift-left')
                end
            end

            self.entity.x = self.entity.x + PLAYER_WALK_SPEED * dt
        elseif self.entity.direction == 'right' then

            self.entity.x = self.entity.x + PLAYER_WALK_SPEED * dt

            for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
                if self.entity:collides(doorway) and doorway.open then

                    self.entity.y = doorway.y + 4
                    Event.dispatch('shift-right')
                end
            end

            self.entity.x = self.entity.x - PLAYER_WALK_SPEED * dt
        elseif self.entity.direction == 'up' then

            self.entity.y = self.entity.y - PLAYER_WALK_SPEED * dt

            for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
                if self.entity:collides(doorway) and doorway.open then

                    self.entity.x = doorway.x + 8
                    Event.dispatch('shift-up')
                end
            end

            self.entity.y = self.entity.y + PLAYER_WALK_SPEED * dt
        else

            self.entity.y = self.entity.y + PLAYER_WALK_SPEED * dt

            for k, doorway in pairs(self.dungeon.currentRoom.doorways) do
                if self.entity:collides(doorway) and doorway.open then

                    self.entity.x = doorway.x + 8
                    Event.dispatch('shift-down')
                end
            end

            self.entity.y = self.entity.y - PLAYER_WALK_SPEED * dt
        end
    end
end
