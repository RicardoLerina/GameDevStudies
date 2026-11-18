-- Demo static: uma caixa estática fica parada no ar, ignorando a gravidade.

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

-- Configura a janela, a tela virtual e a caixa
function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('static')
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    -- Configura a tela virtual com ampliação normal
    push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = 'normal' })

    -- Mundo físico com gravidade para baixo (300)
    world = love.physics.newWorld(0, 300)

    -- Corpo estático: não se move com a gravidade nem com colisões
    boxBody = love.physics.newBody(world, VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2, 'static')
    boxShape = love.physics.newRectangleShape(10, 10)

    -- Fixture liga a forma ao corpo
    boxFixture = love.physics.newFixture(boxBody, boxShape)
end

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

-- Desenha a caixa dentro da tela virtual
function love.draw()
    push.start()
    love.graphics.polygon('fill', boxBody:getWorldPoints(boxShape:getPoints()))
    push.finish()
end
