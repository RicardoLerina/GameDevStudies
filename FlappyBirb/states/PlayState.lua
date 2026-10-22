PlayState = Class{__includes = BaseState}

PIPE_SPEED = 60
PIPE_WIDTH = 70
PIPE_HEIGHT = 288

BIRD_WIDTH = 38
BIRD_HEIGHT = 24

function PlayState:init()
    self.bird = Bird()
    self.pipePairs = {}
    self.timer = 0
    self.score = 0

    -- Where the last gap was placed. Each new gap starts from this value, so
    -- the course changes gradually and stays playable.
    self.lastY = -PIPE_HEIGHT + math.random(80) + 20
end

function PlayState:update(dt)
    self.timer = self.timer + dt

    -- Spawn a new pipe pair every 2 seconds.
    if self.timer > 2 then
        -- Shift the gap up or down by at most 20 pixels from the last one,
        -- clamped so the upper pipe always shows at least 10 pixels and the
        -- gap never goes below the bottom of the screen.
        local y = math.max(-PIPE_HEIGHT + 10,
            math.min(self.lastY + math.random(-20, 20), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
        self.lastY = y

        table.insert(self.pipePairs, PipePair(y))

        self.timer = 0
    end

    for k, pair in pairs(self.pipePairs) do
        -- A pair counts as passed once its right edge is behind the bird.
        -- The scored flag stops the same pair from scoring every frame.
        if not pair.scored then
            if pair.x + PIPE_WIDTH < self.bird.x then
                self.score = self.score + 1
                pair.scored = true
                gSounds['score']:play()
            end
        end

        pair:update(dt)
    end

    -- Off-screen pairs are deleted in a separate pass after every pair has
    -- moved. table.remove shifts the later indices down, so deleting inside
    -- the loop above would make it skip updating the next pair.
    for k, pair in pairs(self.pipePairs) do
        if pair.remove then
            table.remove(self.pipePairs, k)
        end
    end

    for k, pair in pairs(self.pipePairs) do
        for l, pipe in pairs(pair.pipes) do
            if self.bird:collides(pipe) then
                gSounds['explosion']:play()
                gSounds['hurt']:play()

                gStateMachine:change('score', {
                    score = self.score
                })
            end
        end
    end

    self.bird:update(dt)

    -- Touching the ground also ends the run.
    if self.bird.y > VIRTUAL_HEIGHT - 15 then
        gSounds['explosion']:play()
        gSounds['hurt']:play()

        gStateMachine:change('score', {
            score = self.score
        })
    end
end

function PlayState:render()
    for k, pair in pairs(self.pipePairs) do
        pair:render()
    end

    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(self.score), 8, 8)

    self.bird:render()
end

-- Background and ground scroll only while the player is in this state, so
-- the world freezes on the score screen.
function PlayState:enter()
    scrolling = true
end

function PlayState:exit()
    scrolling = false
end
