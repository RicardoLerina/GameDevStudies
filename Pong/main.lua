push = require 'push'

Class = require 'class'

-- our Paddle class
require 'Paddle'

-- our Ball class
require 'Ball'

-- size of our actual window
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- size we're trying to emulate with push
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- paddle movement speed
PADDLE_SPEED = 200

-- AI behaviour for each difficulty:
--   speed           - maximum paddle speed the AI may use
--   acceleration    - how fast (pixels/s²) the paddle can change its speed
--   deadZone        - distance (in pixels) from the target it considers "close enough"
--   predict         - aim at where the ball will arrive instead of where it is now
--   reactionTime    - seconds the AI waits before moving once the ball heads its way
--   guessError      - max distance (in pixels) the first guess can be off by
--   settleTime      - seconds before the ball arrives when the guess is fully refined
--   errorChance     - max probability (0 to 1) of miscalculating the arrival point
--   errorRampRounds - rounds it takes for the chance to grow up to errorChance
--   lateErrorChance - probability of miscalculating in long rallies
--   lateErrorRound  - round of the rally from which lateErrorChance applies
--   aimSpread       - how far from the paddle's center the AI may choose to
--                     hit the ball (0 = always the center, 1 = the very edge)
--   serveSpeedMultiplier - multiplies the ball's horizontal speed on serve
-- (a "round" is each time the ball heads towards the AI within a rally)
AI_SETTINGS = {
    ['normal'] = {
        speed = PADDLE_SPEED * 0.6, acceleration = 800, deadZone = 6,
        predict = false, reactionTime = 0, guessError = 0, settleTime = 0,
        errorChance = 0, errorRampRounds = 10,
        lateErrorChance = 0, lateErrorRound = 20,
        aimSpread = 0.4, serveSpeedMultiplier = 1
    },
    ['hard'] = {
        speed = PADDLE_SPEED, acceleration = 1200, deadZone = 2,
        predict = true, reactionTime = 0.3, guessError = 25, settleTime = 0.3,
        errorChance = 0.05, errorRampRounds = 10,
        lateErrorChance = 0.08, lateErrorRound = 20,
        aimSpread = 0.8, serveSpeedMultiplier = 1.3
    }
}

-- vertical speed the ball leaves a paddle with when it hits the very edge;
-- hits closer to the center send it out at a flatter angle
BALL_MAX_BOUNCE_DY = 150

-- how strongly the AI speeds up based on its distance to the target; the
-- paddle moves at (distance * gain) pixels/s, capped by the difficulty speed
AI_STEERING_GAIN = 8

--[[
    Called just once at the beginning of the game; used to set up
    game objects, variables, etc. and prepare the game world.
]]
function love.load()
    -- set LÖVE's default filter to "nearest-neighbor", which essentially
    -- means there will be no filtering of pixels (blurriness)
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- set the title of our application window
    love.window.setTitle('Pong')

    -- seed the random number generator so that calls to random are
    -- always random
    math.randomseed(os.time())

    -- initialize our nice-looking retro text fonts
    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    -- set up our sound effects; later, we can just index this table and
    -- call each entry's `play` method
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        resizable = true,
        fullscreen = false,
        vsync = true
    })

    -- initialize our virtual resolution, which will be rendered within our
    -- actual window no matter its dimensions
    push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = 'normal' })

    -- initialize our player paddles; make them global so that they can be
    -- detected by other functions and modules
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    -- place a ball in the middle of the screen
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- initialize score variables
    player1Score = 0
    player2Score = 0

    -- either going to be 1 or 2; whoever is scored on gets to serve the
    -- following turn
    servingPlayer = 1

    -- player who won the game; not set to a proper value until we reach
    -- that state in the game
    winningPlayer = 0

    -- when true, player 2's paddle is controlled by the AI
    player2IsAI = true

    -- AI difficulty; either 'normal' or 'hard' (see AI_SETTINGS)
    aiDifficulty = 'normal'

    -- AI state for the current round of the rally:
    -- whether the ball is heading towards the AI, which round of the rally
    -- this is, how much reaction time is left, the Y position the AI decided
    -- to aim at (nil until decided), how far off its first guess is and how
    -- long the ball still had to travel when that decision was made, and
    -- which spot of the paddle it wants to hit the ball with
    aiTracking = false
    aiRound = 0
    aiReactionTimer = 0
    aiTargetY = nil
    aiGuessOffset = 0
    aiDecisionTime = 0
    aiAimOffset = 0

    -- the state of our game; can be any of the following:
    -- 1. 'start' (the beginning of the game, before first serve)
    -- 2. 'serve' (waiting on a key press to serve the ball)
    -- 3. 'play' (the ball is in play, bouncing between paddles)
    -- 4. 'done' (the game is over, with a victor, ready for restart)
    gameState = 'start'
end

--[[
    Called whenever we change the dimensions of our window, as by dragging
    out its bottom corner, for example.
]]
function love.resize(w, h)
    push.resize(w, h)
end

--[[
    Called every frame, passing in `dt` since the last frame. `dt`
    is short for `deltaTime` and is measured in seconds.
]]
function love.update(dt)
    if gameState == 'serve' then
        -- before switching to play, initialize ball's velocity based
        -- on the player who last scored
        -- on hard, the ball is served faster
        local serveSpeed = math.random(140, 200)
        if player2IsAI then
            serveSpeed = serveSpeed * AI_SETTINGS[aiDifficulty].serveSpeedMultiplier
        end

        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = serveSpeed
        else
            ball.dx = -serveSpeed
        end
    elseif gameState == 'play' then
        -- detect ball collision with paddles, reversing dx if true and
        -- slightly increasing it, then altering the dy based on the position
        -- of collision, and finally playing a sound effect
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5
            ball.dy = paddleBounceDy(player1)

            sounds['paddle_hit']:play()
        end
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4
            ball.dy = paddleBounceDy(player2)

            sounds['paddle_hit']:play()
        end

        -- detect upper and lower screen boundary collision, playing a sound
        -- effect and reversing dy if true
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        -- -4 to account for the ball's size
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        -- if we reach the left or right edge of the screen, go back to serve
        -- and update the score and serving player
        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()

            -- if we've reached a score of 10, the game is over; set the
            -- state to done so we can show the victory message
            if player2Score == 10 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                -- place the ball in the middle of the screen, no velocity
                ball:reset()
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()

            if player1Score == 10 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end

    --
    -- paddles can move no matter what state we're in
    --
    -- player 1
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    -- player 2 (controlled by the AI or by the keyboard)
    if player2IsAI then
        updateAI(player2, dt)
    elseif love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    -- update our ball based on its DX and DY only if we're in play state;
    -- scale the velocity by dt so movement is framerate-independent
    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end

--[[
    A callback that processes key strokes as they happen, just the once.
    Does not account for keys that are held down, which is handled by a
    separate function (`love.keyboard.isDown`). Useful for when we want
    things to happen right away, just once, like when we want to quit.
]]
function love.keypressed(key)
    -- `key` will be whatever key this callback detected as pressed
    if key == 'escape' then
        -- the function LÖVE2D uses to quit the application
        love.event.quit()
    -- on the start screen, toggle player 2 between AI and human
    elseif key == 'a' and gameState == 'start' then
        player2IsAI = not player2IsAI
    -- on the start screen, toggle the AI difficulty
    elseif key == 'd' and gameState == 'start' and player2IsAI then
        aiDifficulty = aiDifficulty == 'normal' and 'hard' or 'normal'
    -- if we press enter during either the start or serve phase, it should
    -- transition to the next appropriate state
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            -- game is simply in a restart phase here, but will set the serving
            -- player to the opponent of whomever won for fairness!
            gameState = 'serve'

            ball:reset()

            -- reset scores to 0
            player1Score = 0
            player2Score = 0

            -- decide serving player as the opposite of who won
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

--[[
    Called each frame after update; is responsible simply for
    drawing all of our game objects and more to the screen.
]]
function love.draw()
    -- begin drawing with push, in our virtual resolution
    push.start()

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    -- render different things depending on which part of the game we're in
    if gameState == 'start' then
        -- UI messages
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Player 2: ' .. (player2IsAI and 'CPU' or 'Human') ..
            ' (press A to toggle)', 0, 30, VIRTUAL_WIDTH, 'center')
        if player2IsAI then
            love.graphics.printf('Difficulty: ' .. aiDifficulty .. ' (press D to toggle)',
                0, 40, VIRTUAL_WIDTH, 'center')
        end
    elseif gameState == 'serve' then
        -- UI messages
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!",
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        -- no UI messages to display in play
    elseif gameState == 'done' then
        -- UI messages
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    -- show the score before ball is rendered so it can move over the text
    displayScore()

    player1:render()
    player2:render()
    ball:render()

    -- display FPS for debugging; simply comment out to remove
    displayFPS()

    -- end our drawing to push
    push.finish()
end

--[[
    Returns the ball's new vertical speed after hitting the given paddle,
    based on where it hit: the center sends it out straight, while hits
    near the top or bottom edge send it out at a steeper angle towards
    that side.
]]
function paddleBounceDy(paddle)
    local ballCenter = ball.y + ball.height / 2
    local paddleCenter = paddle.y + paddle.height / 2

    -- -1 at the very top of the paddle, 0 at its center, 1 at the very
    -- bottom (the ball can overlap the edge by up to half its height)
    local hitPosition = (ballCenter - paddleCenter) / (paddle.height / 2 + ball.height / 2)

    return clamp(hitPosition, -1, 1) * BALL_MAX_BOUNCE_DY
end

--[[
    Decides the movement of an AI-controlled paddle by setting `paddle.dy`
    based on the ball's position and velocity. The actual movement (and
    clamping to the screen) is still handled by `Paddle:update`.
]]
function updateAI(paddle, dt)
    local settings = AI_SETTINGS[aiDifficulty]
    local paddleCenter = paddle.y + paddle.height / 2
    local targetY

    -- only react while the ball is actually in play; during serve its
    -- velocity is re-rolled every frame, so predicting it would be useless
    if gameState == 'play' and ball.dx > 0 then
        -- the ball just started heading towards us: a new round begins
        if not aiTracking then
            aiTracking = true
            aiRound = aiRound + 1
            aiReactionTimer = settings.reactionTime
            aiTargetY = nil

            -- pick the spot of the paddle to hit the ball with (positive is
            -- below the center); off-center hits send the ball at an angle
            aiAimOffset = (math.random() * 2 - 1) * settings.aimSpread * paddle.height / 2
        end

        if aiReactionTimer > 0 then
            -- still reacting: targetY stays nil, so the paddle slows to a stop
            aiReactionTimer = aiReactionTimer - dt
        elseif settings.predict then
            -- decide the arrival point only once per round, so a
            -- miscalculation sticks instead of being fixed on the next frame
            if not aiTargetY then
                aiTargetY = predictBallY(paddle.x) + ball.height / 2
                if math.random() < aiErrorChance(settings, aiRound) then
                    aiTargetY = aiTargetY + missOffset(paddle, aiTargetY)
                    -- aiming would shift the paddle and could undo the miss
                    aiAimOffset = 0
                end

                -- the first guess is a bit off, like a human eyeballing it
                aiGuessOffset = (math.random() * 2 - 1) * settings.guessError
                aiDecisionTime = ballTimeToReach(paddle.x)
            end

            -- the guess gets refined as the ball approaches, reaching the
            -- decided target `settleTime` seconds before the ball arrives
            local refineSpan = aiDecisionTime - settings.settleTime
            local uncertainty = 0
            if refineSpan > 0 then
                uncertainty = clamp((ballTimeToReach(paddle.x) - settings.settleTime) /
                    refineSpan, 0, 1)
            end
            targetY = aiTargetY - aiAimOffset + aiGuessOffset * uncertainty
        else
            -- simply follow the ball's current position
            targetY = ball.y + ball.height / 2 - aiAimOffset
        end
    else
        -- ball is moving away (or not in play): drift back to the middle of
        -- the screen to be ready for the next shot
        aiTracking = false
        targetY = VIRTUAL_HEIGHT / 2

        -- a point was scored, so the next rally starts counting from zero
        if gameState ~= 'play' then
            aiRound = 0
        end
    end

    -- the speed the AI would like to have right now; slower when close to
    -- the target so it eases in instead of stopping abruptly, and zero when
    -- close enough (avoids jitter) or when it has no target yet
    local desiredDy = 0
    if targetY then
        local diff = targetY - paddleCenter
        if math.abs(diff) > settings.deadZone then
            desiredDy = clamp(diff * AI_STEERING_GAIN, -settings.speed, settings.speed)
        end
    end

    -- accelerate towards the desired speed instead of reaching it instantly
    local maxChange = settings.acceleration * dt
    paddle.dy = paddle.dy + clamp(desiredDy - paddle.dy, -maxChange, maxChange)
end

--[[
    Returns the chance of the AI miscalculating in the given round of the
    rally: it grows from zero up to `errorChance` over the first
    `errorRampRounds` rounds, and jumps to `lateErrorChance` from round
    `lateErrorRound` on.
]]
function aiErrorChance(settings, round)
    if round >= settings.lateErrorRound then
        return settings.lateErrorChance
    end

    return settings.errorChance * math.min(round / settings.errorRampRounds, 1)
end

--[[
    Returns how many seconds the ball needs to reach the given X. Assumes
    the ball is moving right (ball.dx > 0).
]]
function ballTimeToReach(targetX)
    return (targetX - (ball.x + ball.width)) / ball.dx
end

--[[
    Predicts the Y position the ball will have when it reaches the given X,
    simulating its bounces off the top and bottom walls. Assumes the ball
    is moving right (ball.dx > 0).
]]
function predictBallY(targetX)
    local y = ball.y + ball.dy * ballTimeToReach(targetX)

    -- the ball travels between 0 and maxY; "unfolding" the bounces means
    -- the path repeats every 2 * maxY, and the second half is mirrored
    local maxY = VIRTUAL_HEIGHT - ball.height
    y = y % (2 * maxY)
    if y > maxY then
        y = 2 * maxY - y
    end

    return y
end

--[[
    Returns an offset that, added to the correct target, makes the paddle
    miss the ball. The offset points away from the nearest wall so the
    paddle isn't pushed back onto the ball by the screen limits.
]]
function missOffset(paddle, targetY)
    -- the paddle misses when its center is more than half its height plus
    -- half the ball's height away from the ball's center
    local minMiss = paddle.height / 2 + ball.height / 2 + 4
    local offset = math.random(minMiss, minMiss + 15)

    if targetY + offset > VIRTUAL_HEIGHT - paddle.height / 2 then
        return -offset
    elseif targetY - offset < paddle.height / 2 then
        return offset
    end

    return math.random(2) == 1 and offset or -offset
end

--[[
    Limits a value to the range [min, max].
]]
function clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

--[[
    Simple function for rendering the scores.
]]
function displayScore()
    -- score display
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50,
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
end

--[[
    Renders the current FPS.
]]
function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255/255, 0, 255/255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(255, 255, 255, 255)
end
