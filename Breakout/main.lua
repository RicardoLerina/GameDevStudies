-- Graphics by buch (https://opengameart.org/users/buch).
-- Music by joshuaempyre (http://freesound.org/people/joshuaempyre/sounds/251461/).

require 'src.Dependencies'

function love.load()
    -- Nearest-neighbor filtering keeps pixel art sharp when scaled.
    love.graphics.setDefaultFilter('nearest', 'nearest')

    math.randomseed(os.time())

    love.window.setTitle('Breakout')

    gFonts = {
        ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
        ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
        ['large'] = love.graphics.newFont('fonts/font.ttf', 32)
    }
    love.graphics.setFont(gFonts['small'])

    -- Assets are loaded once here and shared globally, instead of each object
    -- loading its own copy.
    gTextures = {
        ['background'] = love.graphics.newImage('graphics/background.png'),
        ['main'] = love.graphics.newImage('graphics/breakout.png'),
        ['arrows'] = love.graphics.newImage('graphics/arrows.png'),
        ['hearts'] = love.graphics.newImage('graphics/hearts.png'),
        ['particle'] = love.graphics.newImage('graphics/particle.png')
    }

    -- Most sprites live together in one sheet, so each frame is a quad that
    -- points to a region of its texture.
    gFrames = {
        ['arrows'] = GenerateQuads(gTextures['arrows'], 24, 24),
        ['paddles'] = GenerateQuadsPaddles(gTextures['main']),
        ['balls'] = GenerateQuadsBalls(gTextures['main']),
        ['bricks'] = GenerateQuadsBricks(gTextures['main']),
        ['hearts'] = GenerateQuads(gTextures['hearts'], 10, 9)
    }

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = 'normal' })

    gSounds = {
        ['paddle-hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall-hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
        ['confirm'] = love.audio.newSource('sounds/confirm.wav', 'static'),
        ['select'] = love.audio.newSource('sounds/select.wav', 'static'),
        ['no-select'] = love.audio.newSource('sounds/no-select.wav', 'static'),
        ['brick-hit-1'] = love.audio.newSource('sounds/brick-hit-1.wav', 'static'),
        ['brick-hit-2'] = love.audio.newSource('sounds/brick-hit-2.wav', 'static'),
        ['hurt'] = love.audio.newSource('sounds/hurt.wav', 'static'),
        ['victory'] = love.audio.newSource('sounds/victory.wav', 'static'),
        ['recover'] = love.audio.newSource('sounds/recover.wav', 'static'),
        ['high-score'] = love.audio.newSource('sounds/high_score.wav', 'static'),
        ['pause'] = love.audio.newSource('sounds/pause.wav', 'static'),

        ['music'] = love.audio.newSource('sounds/music.wav', 'static')
    }

    -- Each entry is a factory function, so every state change builds a fresh
    -- state object. Game data (paddle, bricks, score...) travels between
    -- states through the params table passed to change().
    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['play'] = function() return PlayState() end,
        ['serve'] = function() return ServeState() end,
        ['game-over'] = function() return GameOverState() end,
        ['victory'] = function() return VictoryState() end,
        ['high-scores'] = function() return HighScoreState() end,
        ['enter-high-score'] = function() return EnterHighScoreState() end,
        ['paddle-select'] = function() return PaddleSelectState() end
    }
    gStateMachine:change('start', {
        highScores = loadHighScores()
    })

    -- The music lives outside the states so it keeps playing across screens.
    gSounds['music']:play()
    gSounds['music']:setLooping(true)

    -- LÖVE only reports key presses through a callback, so they are stored
    -- here for the current frame and states can query them with wasPressed.
    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push.resize(w, h)
end

function love.update(dt)
    gStateMachine:update(dt)

    -- Cleared after the update so each press counts for a single frame.
    love.keyboard.keysPressed = {}
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function love.draw()
    push.start()

    -- The background is drawn for every state, stretched to fill the virtual
    -- resolution. Subtracting 1 from its size hides a seam at the edges.
    local backgroundWidth = gTextures['background']:getWidth()
    local backgroundHeight = gTextures['background']:getHeight()

    love.graphics.draw(gTextures['background'],
        0, 0,
        0,
        VIRTUAL_WIDTH / (backgroundWidth - 1), VIRTUAL_HEIGHT / (backgroundHeight - 1))

    gStateMachine:render()

    displayFPS()

    push.finish()
end

-- High scores are stored in LÖVE's save directory as alternating lines of
-- name and score.
function loadHighScores()
    love.filesystem.setIdentity('breakout')

    -- On the first run there is no file yet, so create one with placeholder
    -- scores from 10000 down to 1000.
    if not love.filesystem.getInfo('breakout.lst') then
        local scores = ''
        for i = 10, 1, -1 do
            scores = scores .. 'CTO\n'
            scores = scores .. tostring(i * 1000) .. '\n'
        end

        love.filesystem.write('breakout.lst', scores)
    end

    -- Tells whether the next line is a name or a score.
    local name = true
    local currentName = nil
    local counter = 1

    local scores = {}

    for i = 1, 10 do
        scores[i] = {
            name = nil,
            score = nil
        }
    end

    for line in love.filesystem.lines('breakout.lst') do
        if name then
            scores[counter].name = string.sub(line, 1, 3)
        else
            scores[counter].score = tonumber(line)
            counter = counter + 1
        end

        name = not name
    end

    return scores
end

-- Draws full hearts for the health left, then empty ones up to the max of 3.
function renderHealth(health)
    local healthX = VIRTUAL_WIDTH - 100

    for i = 1, health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][1], healthX, 4)
        healthX = healthX + 11
    end

    for i = 1, 3 - health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][2], healthX, 4)
        healthX = healthX + 11
    end
end

function displayFPS()
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 5)
    love.graphics.setColor(1, 1, 1, 1)
end

function renderScore(score)
    love.graphics.setFont(gFonts['small'])
    love.graphics.print('Score:', VIRTUAL_WIDTH - 60, 5)
    -- Right-aligned so the label stays put as the number grows.
    love.graphics.printf(tostring(score), VIRTUAL_WIDTH - 50, 5, 40, 'right')
end
