Pipe = Class{}

function Pipe:init(orientation, y)
    self.x = VIRTUAL_WIDTH + 64
    self.y = y

    self.width = PIPE_WIDTH
    self.height = PIPE_HEIGHT

    self.orientation = orientation
end

function Pipe:update(dt)

end

-- The same sprite is used for both pipes. A top pipe is mirrored vertically
-- (scale Y = -1), which flips it around its origin, so it is drawn PIPE_HEIGHT
-- lower to bring it back into place.
function Pipe:render()
    love.graphics.draw(gTextures['pipe'], self.x,
        (self.orientation == 'top' and self.y + PIPE_HEIGHT or self.y),
        0, 1, self.orientation == 'top' and -1 or 1)
end
