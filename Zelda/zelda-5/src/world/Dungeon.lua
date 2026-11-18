Dungeon = Class{}

-- sets up the player, first room and camera state
function Dungeon:init(player, rooms, startX, startY)
    self.player = player

    self.rooms = rooms or {}

    self.currentRoom = rooms[startY][startX]

    self.nextRoom = nil

    self.cameraX = 0
    self.cameraY = 0
end

-- updates the active room and any running camera shift
function Dungeon:update(dt)
    self.currentRoom:update(dt)
end

-- draws the current room (and the next one while shifting)
function Dungeon:render()
    self.currentRoom:render()

    if self.nextRoom then
        self.nextRoom:render()
    end
end
