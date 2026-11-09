-- Board: an 8x8 grid of tiles. Finds matches, clears them, makes the
-- remaining tiles fall and refills the empty spaces from the top.

Board = Class{}

-- x, y: top-left corner of the board on screen, in virtual pixels.
function Board:init(x, y)
    self.x = x
    self.y = y
    self.matches = {}

    self:initializeTiles()
end

-- Fills the grid with random tiles. tiles[y][x] is indexed row first.
function Board:initializeTiles()
    self.tiles = {}

    for tileY = 1, 8 do
        table.insert(self.tiles, {})

        for tileX = 1, 8 do
            table.insert(self.tiles[tileY], Tile(tileX, tileY, math.random(18), math.random(6)))
        end
    end

    -- A fresh board must not start with ready-made matches, so keep
    -- rerolling until we get one without any.
    while self:calculateMatches() do
        self:initializeTiles()
    end
end

-- Scans every row and column for runs of 3+ tiles of the same color.
-- Stores the result in self.matches (a list of lists of tiles) and returns
-- it, or returns false when there is nothing to clear.
function Board:calculateMatches()
    local matches = {}

    local matchNum = 1

    -- Horizontal runs.
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color

        matchNum = 1

        for x = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                -- The run ended; start counting the new color from here.
                colorToMatch = self.tiles[y][x].color

                if matchNum >= 3 then
                    local match = {}

                    -- Walk back over the run that just ended.
                    for x2 = x - 1, x - matchNum, -1 do
                        table.insert(match, self.tiles[y][x2])
                    end

                    table.insert(matches, match)
                end

                matchNum = 1

                -- Fewer than 3 cells remain in this row, no new run can fit.
                if x >= 7 then
                    break
                end
            end
        end

        -- A run that reaches the right edge never hits the "else" above.
        if matchNum >= 3 then
            local match = {}

            for x = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(matches, match)
        end
    end

    -- Vertical runs: same idea, walking down each column.
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color

        matchNum = 1

        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[y][x].color

                if matchNum >= 3 then
                    local match = {}

                    for y2 = y - 1, y - matchNum, -1 do
                        table.insert(match, self.tiles[y2][x])
                    end

                    table.insert(matches, match)
                end

                matchNum = 1

                if y >= 7 then
                    break
                end
            end
        end

        if matchNum >= 3 then
            local match = {}

            for y = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(matches, match)
        end
    end

    self.matches = matches

    return #self.matches > 0 and self.matches or false
end

-- Exchanges two tiles in the grid and updates their grid coordinates.
-- Only the logical position changes; the caller animates x/y on screen.
function Board:swapTiles(tileA, tileB)
    local ax, ay = tileA.gridX, tileA.gridY

    tileA.gridX, tileA.gridY = tileB.gridX, tileB.gridY
    tileB.gridX, tileB.gridY = ax, ay

    self.tiles[tileA.gridY][tileA.gridX] = tileA
    self.tiles[tileB.gridY][tileB.gridX] = tileB
end

-- Leaves a nil hole in the grid for every tile that was part of a match.
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end

-- Moves tiles down into the holes left by removeMatches and creates new
-- tiles above the board for whatever is still empty. Returns a table in
-- the format Timer.tween expects: { [tile] = { y = targetY } }.
function Board:getFallingTiles()
    local tweens = {}

    for x = 1, 8 do
        -- space: we are currently above a hole.
        -- spaceY: the lowest empty row found so far in this column.
        local space = false
        local spaceY = 0

        -- Walk the column bottom to top so tiles fall into the lowest gap.
        local y = 8
        while y >= 1 do
            local tile = self.tiles[y][x]

            if space then
                if tile then
                    -- Drop this tile into the gap.
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    self.tiles[y][x] = nil

                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- Restart the scan just above the cell we filled, since
                    -- that is now the lowest possible gap.
                    space = false
                    y = spaceY

                    spaceY = 0
                end
            elseif tile == nil then
                space = true

                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- Any cell still empty gets a new tile that starts just above the board
    -- and slides into place.
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            if not tile then
                local tile = Tile(x, y, math.random(18), math.random(6))
                tile.y = -32
                self.tiles[y][x] = tile

                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
end
