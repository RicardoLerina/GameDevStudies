-- Ponto de entrada do Angry 50: um jogo estilo Angry Birds com física Box2D.
-- Configura janela, tela virtual, máquina de estados e a entrada de teclado e mouse.

-- Filtro 'nearest' mantém o pixel art nítido ao ampliar
love.graphics.setDefaultFilter('nearest', 'nearest')

-- Carrega bibliotecas, assets e classes do jogo
require 'src.Dependencies'

-- Silencia avisos de funções obsoletas em versões novas do LÖVE
local major, minor = love.getVersion()
if major > 11 then
    love.setDeprecationOutput(false)
end

-- Inicializa janela, estados, música e tabelas de entrada
function love.load()
    math.randomseed(os.time())
    love.window.setTitle('Angry 50')
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })
    push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = 'normal' })
    -- Estados do jogo: tela inicial e partida
    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['play'] = function() return PlayState() end
    }
    gStateMachine:change('start')
    -- Música de fundo em loop
    gSounds['music']:setLooping(true)
    gSounds['music']:play()
    -- Tabelas de teclas e botões do mouse no frame atual
    love.keyboard.keysPressed = {}
    love.mouse.keysPressed = {}
    love.mouse.keysReleased = {}
    -- Flag de pausa, alternada com a tecla P
    paused = false
end

-- Redimensionamento da janela
function push.resize(w, h)
    push.resize(w, h)
end

-- Tecla P alterna a pausa; registra a tecla pressionada
function love.keypressed(key)
    if key == 'p' then
        paused = not paused
    end
    love.keyboard.keysPressed[key] = true
end

-- Registra o botão do mouse pressionado
function love.mousepressed(x, y, key)
    love.mouse.keysPressed[key] = true
end

-- Registra o botão do mouse solto
function love.mousereleased(x, y, key)
    love.mouse.keysReleased[key] = true
end

-- Consulta se a tecla foi pressionada neste frame
function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

-- Consulta se o botão do mouse foi pressionado neste frame
function love.mouse.wasPressed(key)
    return love.mouse.keysPressed[key]
end

-- Consulta se o botão do mouse foi solto neste frame
function love.mouse.wasReleased(key)
    return love.mouse.keysReleased[key]
end

-- Atualiza o estado atual, exceto quando o jogo está pausado
function love.update(dt)
    if not paused then
        gStateMachine:update(dt)
        love.keyboard.keysPressed = {}
        love.mouse.keysPressed = {}
        love.mouse.keysReleased = {}
    end
end

-- Desenha o estado atual dentro da tela virtual
function love.draw()
    push.start()
    gStateMachine:render()
    push.finish()
end
