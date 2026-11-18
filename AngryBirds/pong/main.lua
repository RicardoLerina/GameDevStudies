-- Demo pong: Pong para dois jogadores usando física Box2D.
-- Jogador 1: W/S. Jogador 2: setas. Vence quem chegar a 10 pontos.

-- Resolução virtual (arte) e tamanho real da janela
VIRTUAL_WIDTH,  VIRTUAL_HEIGHT  = 640, 360
WINDOW_WIDTH,   WINDOW_HEIGHT   = 1280, 720

-- Tamanho das raquetes, da bola e velocidades
PADDLE_W, PADDLE_H  = 6, 42
BALL_RADIUS         = 4
PADDLE_SPEED        = 160
SERVE_SPEED         = 140

-- Biblioteca de escala de tela virtual
push = require "push"

-- Silencia avisos de funções obsoletas em versões novas do LÖVE
local major = love.getVersion()
if major > 11 then love.setDeprecationOutput(false) end

-- Teclas atualmente seguradas
local keysDown = {}

-- Estado da partida: direção do saque, velocidade da bola, fase e vencedor
local serveDirection = nil
local ballSpeed = SERVE_SPEED
local gameState = 'start'
local winner = nil

-- ESC fecha; Enter saca a bola; R reinicia depois do fim
function love.keypressed(k)
    if k == 'escape' then
        love.event.quit()
    end

    keysDown[k] = true
    -- Enter inicia ou retoma a partida e saca a bola
    if (k == 'return' or k == 'enter') and (gameState == 'start' or gameState == 'serve') then
        gameState = 'play'
        serveBall()
    -- R reinicia placar, velocidade e estado
    elseif (k == 'r') and gameState == 'done' then
        lScore, rScore = 0, 0
        winner = nil
        gameState = 'start'
        serveDirection = nil
        ballSpeed = SERVE_SPEED
        serveBall()
    end
end

-- Marca a tecla como solta
function love.keyreleased(k) keysDown[k] = false end

-- Informa se a tecla está sendo segurada
function held(k) return keysDown[k] end

-- Limita um valor ao intervalo [min, max]
function clamp(val, min, max) return math.max(min, math.min(max, val)) end

-- Objetos físicos e placar
local world, ballBody, ballShape, ballFix
local lPadBody, rPadBody, padShape
local lScore, rScore = 0, 0

-- Cria o mundo sem gravidade, as bordas, as raquetes e a bola
function love.load()
    love.window.setTitle("Pong (Box2D demo)")
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, { vsync = true, resizable = true })
    push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = "normal" })
    math.randomseed(os.time())
    love.physics.setMeter(32)
    -- Mundo sem gravidade: a bola só reage a colisões
    world = love.physics.newWorld(0, 0)
    -- Bordas superior e inferior estáticas
    local top    = love.physics.newBody(world, 0, 0, "static")
    local bottom = love.physics.newBody(world, 0, VIRTUAL_HEIGHT, "static")
    local edgeT  = love.physics.newEdgeShape(0, 0, VIRTUAL_WIDTH, 0)
    local edgeB  = love.physics.newEdgeShape(0, 0, VIRTUAL_WIDTH, 0)
    edgeTFix     = love.physics.newFixture(top,    edgeT)
    edgeBFix     = love.physics.newFixture(bottom, edgeB)

    -- Restituição um pouco acima de 1 mantém a bola acelerando nos quiques
    edgeTFix:setRestitution(1.01)
    edgeTFix:setFriction(0)
    edgeBFix:setRestitution(1.01)
    edgeBFix:setFriction(0)
    -- Raquetes cinemáticas: movidas por velocidade, sem serem empurradas pela bola
    padShape  = love.physics.newRectangleShape(PADDLE_W, PADDLE_H)
    lPadBody  = love.physics.newBody(world, 20, VIRTUAL_HEIGHT / 2, "kinematic")
    rPadBody  = love.physics.newBody(world, VIRTUAL_WIDTH - 20, VIRTUAL_HEIGHT / 2, "kinematic")
    lPadFix   = love.physics.newFixture(lPadBody, padShape)
    rPadFix   = love.physics.newFixture(rPadBody, padShape)

    -- Atrito e restituição das raquetes
    lPadFix:setFriction(0.9)
    lPadFix:setRestitution(1.01)
    rPadFix:setFriction(0.9)
    rPadFix:setRestitution(1.01)
    -- Bola dinâmica com restituição 1 (sem perda de energia)
    ballShape = love.physics.newCircleShape(BALL_RADIUS)
    ballBody  = love.physics.newBody(world, VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2, "dynamic")
    ballFix   = love.physics.newFixture(ballBody, ballShape, 1)
    ballFix:setRestitution(1)
    ballFix:setFriction(0.6)
    ballBody:setLinearDamping(0)
    -- Estado inicial da partida
    serveDirection = nil
    ballSpeed = SERVE_SPEED
    gameState = 'start'
    winner = nil
    serveBall()
end

-- Coloca a bola no centro e a lança em um ângulo aleatório
function serveBall()
    ballBody:setPosition(VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2)
    ballBody:setLinearVelocity(0, 0)

    -- Direção do saque: para quem acabou de sofrer o ponto, ou aleatória no início
    local angle
    if serveDirection == 'left' then
        angle = math.rad(math.random(150, 210))
    elseif serveDirection == 'right' then
        angle = math.rad(math.random(-30, 30))
    else
        if math.random() < 0.5 then
            angle = math.rad(math.random(-30, 30))
            serveDirection = 'right'
        else
            angle = math.rad(math.random(150, 210))
            serveDirection = 'left'
        end
    end
    ballBody:setLinearVelocity(
        math.cos(angle) * ballSpeed, math.sin(angle) * ballSpeed)
end

-- Move as raquetes, simula a física e detecta pontos
function love.update(dt)
    if gameState == 'play' then
        -- Raquete esquerda (W/S)
        local vyL = 0
        if held("w")   then vyL = vyL - PADDLE_SPEED end
        if held("s")   then vyL = vyL + PADDLE_SPEED end
        lPadBody:setLinearVelocity(0, vyL)
        -- Raquete direita (setas)
        local vyR = 0
        if held("up")   then vyR = vyR - PADDLE_SPEED end
        if held("down") then vyR = vyR + PADDLE_SPEED end
        rPadBody:setLinearVelocity(0, vyR)
        -- Avança a física e mantém as raquetes dentro da tela
        world:update(dt)
        local halfPad = PADDLE_H / 2
        lPadBody:setY(clamp(lPadBody:getY(), halfPad, VIRTUAL_HEIGHT - halfPad))
        rPadBody:setY(clamp(rPadBody:getY(), halfPad, VIRTUAL_HEIGHT - halfPad))
        -- Bola fora da tela: ponto para o lado oposto; 10 pontos encerram a partida
        local bx = ballBody:getX()
        if bx < 0 then
            rScore = rScore + 1
            if rScore >= 10 then
                winner = 2
                gameState = 'done'
            else
                serveDirection = 'right'
                ballSpeed = ballSpeed * 1.08
                gameState = 'serve'
                serveBall()
            end
        elseif bx > VIRTUAL_WIDTH then
            lScore = lScore + 1
            if lScore >= 10 then
                winner = 1
                gameState = 'done'
            else
                serveDirection = 'left'
                ballSpeed = ballSpeed * 1.08
                gameState = 'serve'
                serveBall()
            end
        end
    else
        lPadBody:setLinearVelocity(0, 0)
        rPadBody:setLinearVelocity(0, 0)
        ballBody:setLinearVelocity(0, 0)
    end
end

-- Desenha rede, raquetes, bola, placar e mensagens
function love.draw()
    push.start()
    love.graphics.setColor(1, 1, 1, 0.2)
    for y = 0, VIRTUAL_HEIGHT, 15 do
        love.graphics.rectangle("fill", VIRTUAL_WIDTH / 2 - 1, y, 2, 10)
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.polygon("fill", lPadBody:getWorldPoints(padShape:getPoints()))
    love.graphics.polygon("fill", rPadBody:getWorldPoints(padShape:getPoints()))
    love.graphics.circle("fill", ballBody:getX(), ballBody:getY(), BALL_RADIUS)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf(lScore .. "   " .. rScore, 0, 10, VIRTUAL_WIDTH, "center")

    love.graphics.setFont(love.graphics.newFont(16))
    if gameState == 'start' then
        love.graphics.printf("Press Enter to serve!", 0, VIRTUAL_HEIGHT / 2 - 20, VIRTUAL_WIDTH, "center")
    elseif gameState == 'serve' then
        love.graphics.printf("Press Enter to serve!", 0, VIRTUAL_HEIGHT / 2 - 20, VIRTUAL_WIDTH, "center")
    elseif gameState == 'done' then
        love.graphics.setFont(love.graphics.newFont(32))
        love.graphics.printf("Player " .. winner .. " wins!", 0, VIRTUAL_HEIGHT / 2 - 32, VIRTUAL_WIDTH, "center")
        love.graphics.setFont(love.graphics.newFont(16))
        love.graphics.printf("Press R to restart", 0, VIRTUAL_HEIGHT / 2 + 16, VIRTUAL_WIDTH, "center")
    end
    push.finish()
end
