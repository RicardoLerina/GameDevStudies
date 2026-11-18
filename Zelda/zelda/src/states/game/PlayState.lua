PlayState = Class{__includes = BaseState}
local renderMap = false

-- creates the player and the dungeon
function PlayState:init()
    self.player = Player {
        animations = ENTITY_DEFS['player'].animations,
        walkSpeed = ENTITY_DEFS['player'].walkSpeed,

        x = VIRTUAL_WIDTH / 2 - 8,
        y = VIRTUAL_HEIGHT / 2 - 11,

        width = 16,
        height = 22,

        health = 6,

        offsetY = 5
    }

    self.dungeon = DungeonMaker.generate(self.player, 10)
    self.currentRoom = Room(self.player)

    self.player.stateMachine = StateMachine {
        ['walk'] = function() return PlayerWalkState(self.player, self.dungeon) end,
        ['idle'] = function() return PlayerIdleState(self.player) end,
        ['swing-sword'] = function() return PlayerSwingSwordState(self.player, self.dungeon) end
    }
    self.player:changeState('idle')
end

-- handles pause and updates the dungeon
function PlayState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    if love.keyboard.wasPressed('m') then
        renderMap = not renderMap
    end

    self.dungeon:update(dt)
end

-- draws the dungeon and the player HUD
function PlayState:render()

    love.graphics.push()
    self.dungeon:render()
    love.graphics.pop()

    local healthLeft = self.player.health
    local heartFrame = 1

    for i = 1, 3 do
        if healthLeft > 1 then
            heartFrame = 5
        elseif healthLeft == 1 then
            heartFrame = 3
        else
            heartFrame = 1
        end

        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][heartFrame],
            (i - 1) * (TILE_SIZE + 1), 2)

        healthLeft = healthLeft - 2
    end

    if renderMap then
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle('fill', VIRTUAL_WIDTH - 92, 16, 82, 82)
        love.graphics.setColor(1, 1, 1, 0.5)
        for y = 1, #self.dungeon.rooms do
            for x = 1, #self.dungeon.rooms[y] do
                if self.dungeon.rooms[y][x] then
                    if self.dungeon.currentRoom.x == x and
                       self.dungeon.currentRoom.y == y then
                        love.graphics.setColor(1, 0, 0, 0.5)
                    else
                        love.graphics.setColor(0, 1, 0, 0.5)
                    end
                end
                love.graphics.rectangle('fill', (x - 1) * 8 + VIRTUAL_WIDTH - 90,
                        (y - 1) * 8 + 18, 8 - 2, 8 - 2)
                love.graphics.setColor(1, 1, 1, 0.5)
            end
        end
        love.graphics.setColor(1, 1, 1, 1)
    end
end
