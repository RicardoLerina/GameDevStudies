DungeonMaker = Class{}

-- builds the dungeon layout using the generator variant
function DungeonMaker.generateGen(player, maxRooms)
    return coroutine.wrap(function()

        local rooms = {}
        for i = 1, maxRooms do
            rooms[i] = {}
            for j = 1, maxRooms do
                rooms[i][j] = false
            end
        end

        local startX = math.max(1, maxRooms / 2)
        local startY = maxRooms

        local queue = { { x = startX, y = startY } }
        local head = 1
        local visited = { [startX .. ',' .. startY] = true }
        local numRooms = 0

        while head <= #queue and numRooms < maxRooms do

            local current = queue[head]
            head = head + 1

            local cx, cy = current.x, current.y

            if not rooms[cy][cx] then
                rooms[cy][cx] = Room(player, cx, cy)
                numRooms = numRooms + 1
                rooms[cy][cx].order = numRooms
            end

            visited[cx .. ',' .. cy] = true

            coroutine.yield {
                phase = 'visit',
                current = current,
                queue = queue,
                rooms = rooms,
                visited = visited,
                head = head
            }

            local room = rooms[cy][cx]

            local directions = {'up', 'down', 'left', 'right'}
            for i = #directions, 2, -1 do
                local j = math.random(i)
                directions[i], directions[j] = directions[j], directions[i]
            end

            for _, dir in ipairs(directions) do

                if math.random() < 0.4 then
                    goto continue
                end

                local nx, ny = cx, cy

                if     dir == 'up'    then ny = ny - 1
                elseif dir == 'down'  then ny = ny + 1
                elseif dir == 'left'  then nx = nx - 1
                elseif dir == 'right' then nx = nx + 1 end

                local key = nx .. ',' .. ny
                if nx >= 1 and nx <= maxRooms and ny >= 1 and ny <= maxRooms
                    and not visited[key] then
                    visited[key] = true
                    queue[#queue + 1] = { x = nx, y = ny }
                end

                ::continue::
            end

            coroutine.yield {
                phase = 'push',
                current = current,
                queue = queue,
                rooms = rooms,
                visited = visited,
                head = head
            }
        end

        for y = 1, maxRooms do
            for x = 1, maxRooms do
                if rooms[y][x] then
                    rooms[y][x]:generateDoorways(rooms, x, y)
                    coroutine.yield {
                        phase = 'doorways',
                        current = {x = x, y = y},
                        rooms = rooms,
                        visited = visited,
                        queue = queue,
                        head = head
                    }
                end
            end
        end

        coroutine.yield {
            phase = 'done',
            dungeon = Dungeon(player, rooms, startX, startY),
            rooms = rooms,
            visited = visited,
            queue = queue,
            current = {x = startX, y = startY},
            head = head
        }
    end)
end

-- builds the whole dungeon layout from scratch
function DungeonMaker.generate(player, maxRooms)

    local rooms = {}
    for i = 1, maxRooms do
        rooms[i] = {}
        for j = 1, maxRooms do
            rooms[i][j] = false
        end
    end

    local startX = math.max(1, maxRooms / 2)
    local startY = maxRooms

    local queue = { { x = startX, y = startY } }
    local head = 1
    local visited = { [startX .. ',' .. startY] = true }
    local numRooms = 0

    while head <= #queue and numRooms < maxRooms do

        local current = queue[head]
        head = head + 1

        local cx, cy = current.x, current.y

        if not rooms[cy][cx] then
            rooms[cy][cx] = Room(player, cx, cy)
            numRooms = numRooms + 1
            rooms[cy][cx].order = numRooms
        end

        visited[cx .. ',' .. cy] = true

        local room = rooms[cy][cx]

        local directions = {'up', 'down', 'left', 'right'}
        for i = #directions, 2, -1 do
            local j = math.random(i)
            directions[i], directions[j] = directions[j], directions[i]
        end

        for _, dir in ipairs(directions) do

            if math.random() < 0.4 then
                goto continue
            end

            local nx, ny = cx, cy

            if     dir == 'up'    then ny = ny - 1
            elseif dir == 'down'  then ny = ny + 1
            elseif dir == 'left'  then nx = nx - 1
            elseif dir == 'right' then nx = nx + 1 end

            local key = nx .. ',' .. ny
            if nx >= 1 and nx <= maxRooms and ny >= 1 and ny <= maxRooms
                and not visited[key] then
                visited[key] = true
                queue[#queue + 1] = { x = nx, y = ny }
            end

            ::continue::
        end
    end

    for y = 1, maxRooms do
        for x = 1, maxRooms do
            if rooms[y][x] then
                rooms[y][x]:generateDoorways(rooms, x, y)
            end
        end
    end

    return Dungeon(player, rooms, startX, startY)
end
