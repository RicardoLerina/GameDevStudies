-- Demo weld: um martelo formado por cabeça e cabo unidos por uma junta soldada (WeldJoint).
-- As setas empurram a cabeça; B quebra a solda.

-- Resolução virtual (arte) e tamanho real da janela
VIRTUAL_WIDTH,  VIRTUAL_HEIGHT = 640, 360
WINDOW_WIDTH,   WINDOW_HEIGHT  = 1280, 720

-- Biblioteca de escala de tela virtual
push = require "push"

-- Silencia avisos de funções obsoletas em versões novas do LÖVE
if love.getVersion() > 11 then love.setDeprecationOutput(false) end

-- Cria o mundo, o chão, as duas partes do martelo e a solda
function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Weld Joint Demo')
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, { vsync = true, resizable = true })
    push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = "normal" })
    -- Define quantos pixels valem um metro; a gravidade usa 9,81 m/s²
    love.physics.setMeter(32)
    world = love.physics.newWorld(0, 9.81 * 32)
    -- Chão estático largo
    groundBody  = love.physics.newBody(world, 0, VIRTUAL_HEIGHT - 30, "static")
    groundShape = love.physics.newEdgeShape(-1000, 0, 1000, 0)
    love.physics.newFixture(groundBody, groundShape)
    -- Tamanho e posição inicial das partes do martelo
    local headW, headH = 80, 20
    local handleW, handleH = 20, 100
    local startX, startY = VIRTUAL_WIDTH / 2, 80
    -- Cabeça do martelo (mais densa)
    headBody = love.physics.newBody(world, startX, startY, "dynamic")
    headShape= love.physics.newRectangleShape(headW, headH)
    love.physics.newFixture(headBody, headShape, 2)
    -- Cabo do martelo, logo abaixo da cabeça
    handleBody  = love.physics.newBody(world, startX, startY + headH / 2 + handleH / 2,
                                      "dynamic")
    handleShape = love.physics.newRectangleShape(handleW, handleH)
    love.physics.newFixture(handleBody, handleShape, 1)
    -- Solda: une as duas partes no ponto de contato como um corpo rígido
    weld = love.physics.newWeldJoint(
              headBody, handleBody,
              startX, startY + headH / 2,
              false)

    -- Intensidade do empurrão das setas
    PUSH_FORCE = 4000
end

-- ESC fecha; setas empurram a cabeça; B destrói a solda
function love.keypressed(k)
    if k == "escape" then love.event.quit() end
    if k == "left"  then headBody:applyForce(-PUSH_FORCE, 0) end
    if k == "right" then headBody:applyForce( PUSH_FORCE, 0) end
    if k == "b" and weld then
        weld:destroy()
        weld = nil
    end
end

-- Avança a simulação física
function love.update(dt) world:update(dt) end

-- Desenha chão, cabeça, cabo, o ponto de solda e o texto de ajuda
function love.draw()
    push.start()
    love.graphics.setColor(0.5, 0.4, 0.3)
    love.graphics.setLineWidth(3)
    love.graphics.line(groundBody:getWorldPoints(groundShape:getPoints()))
    love.graphics.setColor(0.3, 0.8, 1)
    love.graphics.polygon("fill", headBody:getWorldPoints(headShape:getPoints()))
    love.graphics.setColor(0.2, 0.6, 0.9)
    love.graphics.polygon("fill", handleBody:getWorldPoints(handleShape:getPoints()))
    -- Marca em vermelho o ponto de solda enquanto ela existir
    if weld then
        local ax, ay = weld:getAnchors()
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.circle("fill", ax, ay, 4)
    end
    love.graphics.setColor(1, 1, 1)
    -- Texto de ajuda muda quando a solda é quebrada
    local txt = weld and "B = break weld\nleft/right = push" or "Weld broken!"
    love.graphics.print(txt, 10, 10)

    push.finish()
end

-- Redimensionamento da janela
function push.resize(w, h) push.resize(w, h) end
