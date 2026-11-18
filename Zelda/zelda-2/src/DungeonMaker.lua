DungeonMaker = Class{}

-- builds the whole dungeon layout from scratch
function DungeonMaker.generate(player, maxRooms)

    local rooms = {}
    for i = 1, maxRooms do
        rooms[i] = {}
        for j = 1, maxRooms do
            rooms[i][j] = nil
        end
    end

    local startX = math.min(1, maxRooms / 2)
    local startY = math.min(1, maxRooms / 2)

    local stack = {}
    local visited = {}

    table.insert(stack, {x = startX, y = startY})
    visited[startX .. ',' .. startY] = true
    local numRooms = 0

    while #stack > 0 and numRooms < maxRooms do

        local current = table.remove(stack)

        if not rooms[current.y][current.x] then
            rooms[current.y][current.x] = Room(player, current.x, current.y)
            numRooms = numRooms + 1
        end

        local room = rooms[current.y][current.x]

        local directions = {'up', 'down', 'left', 'right'}
        for i = #directions, 2, -1 do
            local j = math.random(i)
            directions[i], directions[j] = directions[j], directions[i]
        end

        for _, direction in ipairs(directions) do
            local newX, newY = current.x, current.y

            if direction == 'up' then
                newY = newY - 1
            elseif direction == 'down' then
                newY = newY + 1
            elseif direction == 'left' then
                newX = newX - 1
            elseif direction == 'right' then
                newX = newX + 1
            end

            if newX >= 1 and newX <= 10 and newY >= 1 and newY <= 10 and not visited[newX .. ',' .. newY] then
                visited[newX .. ',' .. newY] = true

                table.insert(stack, {x = newX, y = newY})
            end
        end
    end

    return Dungeon(player, rooms, startX, startY)
end
