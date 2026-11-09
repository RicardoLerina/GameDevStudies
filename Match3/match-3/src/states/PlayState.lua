-- PlayState: the actual game. The player moves a cursor over the board,
-- selects a tile, then selects a second tile in the same row or column to
-- swap with. Swaps that create a match score points; swaps that don't are
-- undone. Reach the score goal before the timer hits zero to level up.

PlayState = Class{__includes = BaseState}

-- Seconds a one-cell swap takes, plus extra time per additional cell so
-- long-distance swaps don't look like teleports.
local SWAP_BASE_TIME = 0.1
local SWAP_TIME_PER_CELL = 0.03

function PlayState:init()
    self.transitionAlpha = 1

    -- Cursor position on the board, zero-based (0-7).
    self.boardHighlightX = 0
    self.boardHighlightY = 0

    -- Toggled by a timer to make the cursor blink between two reds.
    self.rectHighlighted = false

    -- False while tiles are animating, so the player can't act mid-move.
    self.canInput = true

    -- First tile the player picked, waiting for a second one to swap with.
    self.highlightedTile = nil

    self.score = 0
    self.timer = 60

    Timer.every(0.5, function()
        self.rectHighlighted = not self.rectHighlighted
    end)

    -- Countdown, with a ticking sound during the last five seconds.
    Timer.every(1, function()
        self.timer = self.timer - 1

        if self.timer <= 5 then
            gSounds['clock']:play()
        end
    end)
end

function PlayState:enter(params)
    self.level = params.level

    -- Reuse the board shown during BeginGameState so it doesn't change.
    self.board = params.board or Board(VIRTUAL_WIDTH - 272, 16)

    self.score = params.score or 0

    -- Each level asks for 1250 more points than the previous one.
    self.scoreGoal = self.level * 1.25 * 1000
end

function PlayState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    if self.timer <= 0 then
        -- Drop every pending timer/tween so nothing fires after we leave.
        Timer.clear()

        gSounds['game-over']:play()

        gStateMachine:change('game-over', {
            score = self.score
        })
    end

    if self.score >= self.scoreGoal then
        Timer.clear()

        gSounds['next-level']:play()

        gStateMachine:change('begin-game', {
            level = self.level + 1,
            score = self.score
        })
    end

    if self.canInput then
        -- Move the cursor, clamped to the 8x8 board.
        if love.keyboard.wasPressed('up') then
            self.boardHighlightY = math.max(0, self.boardHighlightY - 1)
            gSounds['select']:play()
        elseif love.keyboard.wasPressed('down') then
            self.boardHighlightY = math.min(7, self.boardHighlightY + 1)
            gSounds['select']:play()
        elseif love.keyboard.wasPressed('left') then
            self.boardHighlightX = math.max(0, self.boardHighlightX - 1)
            gSounds['select']:play()
        elseif love.keyboard.wasPressed('right') then
            self.boardHighlightX = math.min(7, self.boardHighlightX + 1)
            gSounds['select']:play()
        end

        if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
            -- Grid coordinates are one-based.
            local x = self.boardHighlightX + 1
            local y = self.boardHighlightY + 1

            if not self.highlightedTile then
                -- First pick.
                self.highlightedTile = self.board.tiles[y][x]

            elseif self.highlightedTile == self.board.tiles[y][x] then
                -- Picking the same tile again cancels the selection.
                self.highlightedTile = nil

            elseif not self:isValidMove(self.highlightedTile, x, y) then
                gSounds['error']:play()
                self.highlightedTile = nil

            else
                self:trySwap(self.highlightedTile, self.board.tiles[y][x])
            end
        end
    end

    Timer.update(dt)
end

-- Decides whether the selected tile is allowed to swap with the cell at
-- grid position (x, y). x and y are one-based grid coordinates and are
-- never the selected tile's own cell (that case is handled before).
function PlayState:isValidMove(tile, x, y)
    -- TODO(human)
    return false
end

-- Swaps two tiles on the board and animates them to their new spots.
-- onComplete runs once the animation is finished.
function PlayState:swapTiles(tileA, tileB, onComplete)
    local distance = math.abs(tileA.gridX - tileB.gridX) + math.abs(tileA.gridY - tileB.gridY)
    local duration = SWAP_BASE_TIME + SWAP_TIME_PER_CELL * (distance - 1)

    self.board:swapTiles(tileA, tileB)

    -- Each tile slides to the pixel position the other one occupied.
    Timer.tween(duration, {
        [tileA] = {x = tileB.x, y = tileB.y},
        [tileB] = {x = tileA.x, y = tileA.y}
    })
    :finish(onComplete)
end

-- Performs the player's move. If the swap creates at least one match the
-- normal clear/fall cycle starts; otherwise the tiles slide back to where
-- they were and the move is rejected.
function PlayState:trySwap(tileA, tileB)
    self.canInput = false
    self.highlightedTile = nil

    self:swapTiles(tileA, tileB, function()
        if self.board:calculateMatches() then
            self:calculateMatches()
        else
            gSounds['error']:play()

            -- Swapping the same pair again restores the original layout.
            self:swapTiles(tileA, tileB, function()
                self.canInput = true
            end)
        end
    end)
end

-- Clears any matches on the board, awards points and drops new tiles in.
-- Calls itself again after the fall animation to resolve chain reactions,
-- and only gives control back to the player once the board is stable.
function PlayState:calculateMatches()
    self.highlightedTile = nil

    local matches = self.board:calculateMatches()

    if matches then
        -- Restart the sound so rapid combos each get their own "ding".
        gSounds['match']:stop()
        gSounds['match']:play()

        -- 50 points per tile cleared.
        for k, match in pairs(matches) do
            self.score = self.score + #match * 50
        end

        self.board:removeMatches()

        local tilesToFall = self.board:getFallingTiles()

        Timer.tween(0.25, tilesToFall):finish(function()
            self:calculateMatches()
        end)

    else
        self.canInput = true
    end
end

function PlayState:render()
    self.board:render()

    -- Glow over the selected tile, using additive blending to brighten it.
    if self.highlightedTile then
        love.graphics.setBlendMode('add')

        love.graphics.setColor(1, 1, 1, 96/255)
        love.graphics.rectangle('fill', (self.highlightedTile.gridX - 1) * 32 + (VIRTUAL_WIDTH - 272),
            (self.highlightedTile.gridY - 1) * 32 + 16, 32, 32, 4)

        love.graphics.setBlendMode('alpha')
    end

    -- Blinking cursor outline.
    if self.rectHighlighted then
        love.graphics.setColor(217/255, 87/255, 99/255, 1)
    else
        love.graphics.setColor(172/255, 50/255, 50/255, 1)
    end

    love.graphics.setLineWidth(4)
    love.graphics.rectangle('line', self.boardHighlightX * 32 + (VIRTUAL_WIDTH - 272),
        self.boardHighlightY * 32 + 16, 32, 32, 4)

    -- HUD panel on the left side.
    love.graphics.setColor(56/255, 56/255, 56/255, 234/255)
    love.graphics.rectangle('fill', 16, 16, 186, 116, 4)

    love.graphics.setColor(99/255, 155/255, 1, 1)
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Level: ' .. tostring(self.level), 20, 24, 182, 'center')
    love.graphics.printf('Score: ' .. tostring(self.score), 20, 52, 182, 'center')
    love.graphics.printf('Goal : ' .. tostring(self.scoreGoal), 20, 80, 182, 'center')
    love.graphics.printf('Timer: ' .. tostring(self.timer), 20, 108, 182, 'center')
end
