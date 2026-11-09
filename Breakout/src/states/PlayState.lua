PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.ball = params.ball
    self.level = params.level

    self.recoverPoints = params.recoverPoints

    -- Random horizontal direction, always launched upward.
    self.ball.dx = math.random(-200, 200)
    self.ball.dy = math.random(-50, -60)
end

function PlayState:update(dt)
    -- While paused, nothing updates except the check for unpausing.
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    self.paddle:update(dt)
    self.ball:update(dt)

    if self.ball:collides(self.paddle) then
        -- Move the ball back on top of the paddle first, so it doesn't stay
        -- overlapping and bounce again on the next frame.
        self.ball.y = self.paddle.y - 8

        -- Always send the ball upward. Just flipping dy would send it down
        -- if it clipped the side of the paddle while already going up.
        self.ball.dy = -math.abs(self.ball.dy)
        self.ball.dx = paddleBounceDx(self.paddle, self.ball)

        gSounds['paddle-hit']:play()
    end

    for k, brick in pairs(self.bricks) do

        if brick.inPlay and self.ball:collides(brick) then

            -- Higher tiers are worth much more than higher colors.
            self.score = self.score + (brick.tier * 200 + brick.color * 25)

            brick:hit()

            -- Passing the threshold gives back a heart (max 3) and doubles
            -- the next threshold, up to 100000.
            if self.score > self.recoverPoints then
                self.health = math.min(3, self.health + 1)

                self.recoverPoints = math.min(100000, self.recoverPoints * 2)

                gSounds['recover']:play()
            end

            if self:checkVictory() then
                gSounds['victory']:play()

                gStateMachine:change('victory', {
                    level = self.level,
                    paddle = self.paddle,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    ball = self.ball,
                    recoverPoints = self.recoverPoints
                })
            end

            -- Find which side of the brick was hit by comparing how deep the
            -- ball went into it on each axis. The shallower axis is the one
            -- the ball came through, so that is the direction it bounces.
            local BALL_RADIUS = 4
            local BRICK_W, BRICK_H = brick.width, brick.height

            local cxB, cyB = brick.x + BRICK_W / 2, brick.y + BRICK_H / 2
            local cxb, cyb = self.ball.x + BALL_RADIUS, self.ball.y + BALL_RADIUS

            -- Signed distance between the centers; the sign tells which side
            -- of the brick the ball is on.
            local ox = cxB - cxb
            local oy = cyB - cyb

            -- Overlap on each axis: sum of the half sizes minus the distance
            -- between the centers.
            local px = BRICK_W / 2 + BALL_RADIUS - math.abs(ox)
            local py = BRICK_H / 2 + BALL_RADIUS - math.abs(oy)

            -- Besides flipping the velocity, push the ball out by the overlap
            -- so it doesn't hit the same brick again on the next frame.
            if px < py then
                self.ball.dx = -self.ball.dx
                self.ball.x = self.ball.x + (ox > 0 and -px or px)
            else
                self.ball.dy = -self.ball.dy
                self.ball.y = self.ball.y + (oy > 0 and -py or py)
            end

            -- Each brick hit speeds the ball up a little, until a vertical
            -- speed of 150.
            if math.abs(self.ball.dy) < 150 then
                self.ball.dy = self.ball.dy * 1.02
            end

            -- Only one brick per frame. Hitting two bricks at a corner would
            -- flip the velocity twice and cancel the bounce.
            break
        end
    end

    if self.ball.y >= VIRTUAL_HEIGHT then
        self.health = self.health - 1
        gSounds['hurt']:play()

        if self.health == 0 then
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        else
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                health = self.health,
                score = self.score,
                highScores = self.highScores,
                level = self.level,
                recoverPoints = self.recoverPoints
            })
        end
    end

    -- Updated for every brick, including broken ones, so their last
    -- particles can finish playing.
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- Drawn in a second pass so particles always appear on top of the bricks.
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()
    self.ball:render()

    renderScore(self.score)
    renderHealth(self.health)

    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

-- The ball's horizontal speed depends on where it hit the paddle: straight up
-- from the center, and steeper towards whichever edge it hit.
function paddleBounceDx(paddle, ball)
    local ballCenter = ball.x + ball.width / 2
    local paddleCenter = paddle.x + paddle.width / 2

    -- -1 at the left edge of the paddle, 0 at its center, 1 at the right
    -- edge. The ball can overlap the edge by up to half its width, so that
    -- is included to keep the edges at exactly -1 and 1.
    local hitPosition = (ballCenter - paddleCenter) / (paddle.width / 2 + ball.width / 2)

    return math.max(-1, math.min(1, hitPosition)) * BALL_MAX_BOUNCE_DX
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end
    end

    return true
end
