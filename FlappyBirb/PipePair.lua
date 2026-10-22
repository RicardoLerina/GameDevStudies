PipePair = Class{}

-- Vertical opening between the upper and lower pipe.
local GAP_HEIGHT = 90

function PipePair:init(y)
    self.scored = false

    self.x = VIRTUAL_WIDTH + 32

    -- y is the top of the upper pipe. It is usually negative, so most of that
    -- pipe sits above the screen and only its tip shows.
    self.y = y

    self.pipes = {
        ['upper'] = Pipe('top', self.y),
        ['lower'] = Pipe('bottom', self.y + PIPE_HEIGHT + GAP_HEIGHT)
    }

    -- Set once the pair leaves the screen. PlayState then deletes it.
    self.remove = false
end

function PipePair:update(dt)
    -- The pair owns the horizontal position and copies it to both pipes, so
    -- they always move together.
    if self.x > -PIPE_WIDTH then
        self.x = self.x - PIPE_SPEED * dt
        self.pipes['lower'].x = self.x
        self.pipes['upper'].x = self.x
    else
        self.remove = true
    end
end

function PipePair:render()
    for l, pipe in pairs(self.pipes) do
        pipe:render()
    end
end
