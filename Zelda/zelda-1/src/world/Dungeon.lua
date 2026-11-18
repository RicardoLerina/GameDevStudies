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
end

-- draws the current room (and the next one while shifting)
function Dungeon:render()
    self.currentRoom:render()
end
