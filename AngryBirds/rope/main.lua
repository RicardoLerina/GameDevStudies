-- Demo rope: bola presa por uma junta de corda (RopeJoint), que limita só a distância máxima;
-- diferente do pêndulo, a corda pode afrouxar. As setas dão um empurrão na bola.

-- Resolução virtual (arte) e tamanho real da janela
VIRTUAL_WIDTH,  VIRTUAL_HEIGHT = 640, 360

-- Tamanho real da janela
WINDOW_WIDTH,   WINDOW_HEIGHT  = 1280, 720

-- Biblioteca de escala de tela virtual
push = require "push"

-- Silencia avisos de funções obsoletas em versões novas do LÖVE
if love.getVersion() > 11 then love.setDeprecationOutput(false) end

-- Parâmetros da corda: escala de metros, comprimento, raio, densidade e impulso
local METER            = 32
local ROPE_LENGTH_M    = 3
local BALL_RADIUS_PX   = 18
local BALL_DENSITY     = 4
local NUDGE_IMPULSE    = 120

-- Objetos físicos compartilhados entre as funções
local world
local anchorBody
local ballBody
local ropeJoint

-- Comprimento máximo da corda em pixels
local maxLen = ROPE_LENGTH_M * METER

-- Cria o mundo, a âncora, a bola e a corda
function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setTitle("Revolute Joint Pendulum")
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, { vsync = true, resizable = true })
    push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = "normal" })

    -- Define quantos pixels valem um metro; a gravidade usa 9,81 m/s²
    love.physics.setMeter(METER)
    world = love.physics.newWorld(0, 9.81 * METER)
    -- Âncora estática acima do centro da tela
    local anchorX, anchorY = VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 60
    anchorBody = love.physics.newBody(world, anchorX, anchorY, "static")
    -- Bola dinâmica pendurada abaixo da âncora
    local ballX, ballY = anchorX, anchorY + ROPE_LENGTH_M * METER
    ballBody  = love.physics.newBody(world, ballX, ballY, "dynamic")
    local ballShape = love.physics.newCircleShape(BALL_RADIUS_PX)
    love.physics.newFixture(ballBody, ballShape, BALL_DENSITY)
    -- Corda: impede que a bola se afaste mais que maxLen da âncora
    ropeJoint = love.physics.newRopeJoint(
                    anchorBody, ballBody,
                    anchorX, anchorY,
                    ballBody:getX(), ballBody:getY(),
                    maxLen,
                    false)
end

-- ESC fecha; esquerda e direita aplicam impulsos horizontais na bola
function love.keypressed(key)
    if key == "escape" then love.event.quit() end
    if key == "left"  then ballBody:applyLinearImpulse(-NUDGE_IMPULSE, 0) end
    if key == "right" then ballBody:applyLinearImpulse( NUDGE_IMPULSE, 0) end
end

-- Avança a simulação física
function love.update(dt)
    world:update(dt)
end

-- Desenha a corda, a âncora, a bola e a dica de controles
function love.draw()
    push.start()
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.setLineWidth(3)
    love.graphics.line(anchorBody:getX(), anchorBody:getY(),
                       ballBody:getX(),   ballBody:getY())

    love.graphics.setColor(0.9, 0.6, 0.2)
    love.graphics.circle("fill", anchorBody:getX(), anchorBody:getY(), 6)

    love.graphics.setColor(0.3, 0.7, 1)
    love.graphics.circle("fill", ballBody:getX(), ballBody:getY(), BALL_RADIUS_PX)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("left/right = nudge", 10, 10)
    push.finish()
end

-- Redimensionamento da janela
function push.resize(w, h) push.resize(w, h) end
