Dungeon = Class{}

-- sets up the player, first room and camera state
function Dungeon:init(player, rooms, startX, startY)
    self.player = player

    self.rooms = rooms or {}

    self.currentRoom = rooms[startY][startX]

    self.nextRoom = nil

    self.cameraX = 0
    self.cameraY = 0
    self.shifting = false

    Event.on('shift-left', function()
        self:beginShifting(-VIRTUAL_WIDTH, 0)
    end)

    Event.on('shift-right', function()
        self:beginShifting(VIRTUAL_WIDTH, 0)
    end)

    Event.on('shift-up', function()
        self:beginShifting(0, -VIRTUAL_HEIGHT)
    end)

    Event.on('shift-down', function()
        self:beginShifting(0, VIRTUAL_HEIGHT)
    end)
end

-- starts the camera slide towards the neighbouring room
function Dungeon:beginShifting(shiftX, shiftY)

    self.shifting = true

    local nextRoomX = self.currentRoom.x + (shiftX > 0 and 1 or (shiftX < 0 and -1 or 0))
    local nextRoomY = self.currentRoom.y + (shiftY > 0 and 1 or (shiftY < 0 and -1 or 0))
    self.nextRoom = self.rooms[nextRoomY] and self.rooms[nextRoomY][nextRoomX]

    for k, doorway in pairs(self.nextRoom.doorways) do
        doorway.open = true
    end

    self.nextRoom.adjacentOffsetX = shiftX
    self.nextRoom.adjacentOffsetY = shiftY

    local playerX, playerY = self.player.x, self.player.y

    if shiftX > 0 then
        playerX = VIRTUAL_WIDTH + (MAP_RENDER_OFFSET_X + TILE_SIZE)
    elseif shiftX < 0 then
        playerX = -VIRTUAL_WIDTH + (MAP_RENDER_OFFSET_X + (MAP_WIDTH * TILE_SIZE) - TILE_SIZE - self.player.width)
    elseif shiftY > 0 then
        playerY = VIRTUAL_HEIGHT + (MAP_RENDER_OFFSET_Y + self.player.height / 2)
    else
        playerY = -VIRTUAL_HEIGHT + MAP_RENDER_OFFSET_Y + (MAP_HEIGHT * TILE_SIZE) - TILE_SIZE - self.player.height
    end

    Timer.tween(1, {
        [self] = {cameraX = shiftX, cameraY = shiftY},
        [self.player] = {x = playerX, y = playerY}
    }):finish(function()

        self:finishShifting()

        if shiftX < 0 then
            self.player.x = MAP_RENDER_OFFSET_X + (MAP_WIDTH * TILE_SIZE) - TILE_SIZE - self.player.width
            self.player.direction = 'left'
        elseif shiftX > 0 then
            self.player.x = MAP_RENDER_OFFSET_X + TILE_SIZE
            self.player.direction = 'right'
        elseif shiftY < 0 then
            self.player.y = MAP_RENDER_OFFSET_Y + (MAP_HEIGHT * TILE_SIZE) - TILE_SIZE - self.player.height
            self.player.direction = 'up'
        else
            self.player.y = MAP_RENDER_OFFSET_Y + self.player.height / 2
            self.player.direction = 'down'
        end

        for k, doorway in pairs(self.currentRoom.doorways) do
            doorway.open = false
        end

        for k, object in pairs(self.currentRoom.objects) do
            if object.type == 'switch' then
                object.state = 'unpressed'
            end
        end

        gSounds['door']:play()
    end)
end

-- swaps rooms once the slide has ended and places the player
function Dungeon:finishShifting()

    self.cameraX = 0
    self.cameraY = 0
    self.shifting = false

    self.currentRoom = self.nextRoom
    self.nextRoom = nil

    self.currentRoom.adjacentOffsetX = 0
    self.currentRoom.adjacentOffsetY = 0
end

-- updates the active room and any running camera shift
function Dungeon:update(dt)

    if not self.shifting then
        self.currentRoom:update(dt)
    else

        self.player.currentAnimation:update(dt)
    end
end

-- draws the current room (and the next one while shifting)
function Dungeon:render()

    if self.shifting then
        love.graphics.translate(-math.floor(self.cameraX), -math.floor(self.cameraY))
    end

    self.currentRoom:render()

    if self.nextRoom then
        self.nextRoom:render()
    end
end
