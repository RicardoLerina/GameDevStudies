-- Demo ballpit: 1000 bolinhas coloridas e uma caixa pesada caindo em um poço com paredes.
-- Espaço reposiciona a caixa no topo.

-- Resolução virtual (arte) e tamanho real da janela
VIRTUAL_WIDTH = 640
VIRTUAL_HEIGHT = 360
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- Fatores de conversão entre graus e radianos
DEGREES_TO_RADIANS = 0.0174532925199432957
RADIANS_TO_DEGREES = 57.295779513082320876

-- Biblioteca de escala de tela virtual
push = require 'push'

-- Silencia avisos de funções obsoletas em versões novas do LÖVE
local major, minor = love.getVersion()
if major > 11 then
    love.setDeprecationOutput(false)
end

-- Configura a janela, a tela virtual e o mundo físico
function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('ballpit')

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    -- Configura a tela virtual com ampliação normal
    push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = 'normal' })

    -- Mundo físico com gravidade para baixo (300)
    world = love.physics.newWorld(0, 300)

    -- Chão e paredes estáticos
    groundBody = love.physics.newBody(world, 0, VIRTUAL_HEIGHT - 30, 'static')
    leftWallBody = love.physics.newBody(world, 0, 0, 'static')
    rightWallBody = love.physics.newBody(world, VIRTUAL_WIDTH, 0, 'static')

    -- Formas de aresta: horizontal para o chão e vertical para as paredes
    edgeShape = love.physics.newEdgeShape(0, 0, VIRTUAL_WIDTH, 0)
    wallShape = love.physics.newEdgeShape(0, 0, 0, VIRTUAL_HEIGHT)
    groundFixture = love.physics.newFixture(groundBody, edgeShape)
    leftWallFixture = love.physics.newFixture(leftWallBody, wallShape)
    rightWallFixture = love.physics.newFixture(rightWallBody, wallShape)
    -- Caixa grande com densidade 20, mais pesada que as bolinhas
    personBody = love.physics.newBody(world, math.random(VIRTUAL_WIDTH), 0, 'dynamic')
    personShape = love.physics.newRectangleShape(30, 30)

    personFixture = love.physics.newFixture(personBody, personShape, 20)

    -- Listas de bolinhas, cada uma com uma cor sorteada
    dynamicBodies = {}
    dynamicFixtures = {}
    -- Todas as bolinhas compartilham o mesmo círculo de raio 5
    ballShape = love.physics.newCircleShape(5)
    -- Cria 1000 bolinhas em posições aleatórias
    for i = 1, 1000 do
        table.insert(dynamicBodies, {
            love.physics.newBody(world,
                math.random(VIRTUAL_WIDTH), math.random(VIRTUAL_HEIGHT - 30), 'dynamic'),
            r = math.random(255) / 255,
            g = math.random(255) / 255,
            b = math.random(255) / 255
        })
        table.insert(dynamicFixtures, love.physics.newFixture(dynamicBodies[i][1], ballShape))
    end
end

-- Redimensionamento da janela
function push.resize(w, h)
    push.resize(w, h)
end

-- ESC fecha; espaço joga a caixa de volta ao topo
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
    if key == 'space' then
        personBody:setPosition(math.random(VIRTUAL_WIDTH), 0)
    end
end

-- Avança a simulação física
function love.update(dt)
    world:update(dt)
end

-- Desenha os objetos físicos dentro da tela virtual
function love.draw()
    push.start()
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.setLineWidth(2)
    -- Desenha o chão em vermelho
    love.graphics.line(groundBody:getWorldPoints(edgeShape:getPoints()))
    -- Desenha cada bolinha com a sua cor
    for i = 1, #dynamicBodies do
        love.graphics.setColor(
            dynamicBodies[i].r, dynamicBodies[i].g, dynamicBodies[i].b, 1
        )
        love.graphics.circle('fill',
            dynamicBodies[i][1]:getX(),
            dynamicBodies[i][1]:getY(),
            ballShape:getRadius()
        )
    end
    love.graphics.setColor(1, 1, 1, 1)
    -- Desenha a caixa grande
    love.graphics.polygon('fill', personBody:getWorldPoints(personShape:getPoints()))
    push.finish()
end
