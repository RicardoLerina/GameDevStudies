Paddle = Class{}

function Paddle:init(skin)
    -- Starts centered horizontally, a little above the bottom of the screen.
    self.x = VIRTUAL_WIDTH / 2 - 32
    self.y = VIRTUAL_HEIGHT - 32

    self.dx = 0

    self.width = 64
    self.height = 16

    -- The skin picks the paddle color chosen in PaddleSelectState.
    self.skin = skin

    -- One of the four paddle sizes. It starts at 2 because the smallest one
    -- is too hard to start with.
    self.size = 2
end

function Paddle:update(dt)
    if love.keyboard.isDown('left') then
        self.dx = -PADDLE_SPEED
    elseif love.keyboard.isDown('right') then
        self.dx = PADDLE_SPEED
    else
        self.dx = 0
    end

    -- Clamp to the screen. The right limit subtracts the width because x is
    -- the paddle's left edge.
    if self.dx < 0 then
        self.x = math.max(0, self.x + self.dx * dt)
    else
        self.x = math.min(VIRTUAL_WIDTH - self.width, self.x + self.dx * dt)
    end
end

function Paddle:render()
    -- Each skin has 4 sizes in the quad table, so the skin picks the group
    -- and the size picks the quad inside it.
    love.graphics.draw(gTextures['main'], gFrames['paddles'][self.size + 4 * (self.skin - 1)],
        self.x, self.y)
end
