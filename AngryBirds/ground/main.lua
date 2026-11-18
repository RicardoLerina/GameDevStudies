-- Demo ground: a caixa dinâmica cai e quica em um chão estático.

-- Resolução virtual (arte) e tamanho real da janela
VIRTUAL_WIDTH = 640
VIRTUAL_HEIGHT = 360
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

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
    love.window.setTitle('ground')
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    -- Configura a tela virtual com ampliação normal
    push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = 'normal' })

    -- Mundo físico com gravidade para baixo (300)
    world = love.physics.newWorld(0, 300)

    -- Caixa dinâmica no centro da tela
    boxBody = love.physics.newBody(world, VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2, 'dynamic')
    boxShape = love.physics.newRectangleShape(10, 10)

    boxFixture = love.physics.newFixture(boxBody, boxShape)
    -- Restituição 0,5: a caixa quica perdendo metade da energia
    boxFixture:setRestitution(0.5)

    -- Chão estático formado por uma aresta horizontal
    groundBody = love.physics.newBody(world, 0, VIRTUAL_HEIGHT - 30, 'static')
    edgeShape = love.physics.newEdgeShape(0, 0, VIRTUAL_WIDTH, 0)

    -- Fixture do chão
    groundFixture = love.physics.newFixture(groundBody, edgeShape)
end

-- Redimensionamento da janela
function push.resize(w, h)
    push.resize(w, h)
end

-- ESC fecha a demo
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end

-- Avança a simulação física
function love.update(dt)

    world:update(dt)
end

-- Desenha os objetos físicos dentro da tela virtual
function love.draw()
    push.start()
    -- Caixa em verde
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.polygon('fill', boxBody:getWorldPoints(boxShape:getPoints()))
    -- Chão em vermelho
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.setLineWidth(2)
    love.graphics.line(groundBody:getWorldPoints(edgeShape:getPoints()))
    push.finish()
end
