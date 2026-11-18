-- Demo gui-3: barra de progresso (ProgressBar) animada com tweens.
-- Seta direita enche a barra; seta esquerda esvazia.

-- Filtro 'nearest' mantém o pixel art nítido ao ampliar
love.graphics.setDefaultFilter('nearest', 'nearest')

-- Bibliotecas: timers/tweens, classes e escala de tela
Timer =  require 'lib.knife.timer'
Class = require 'lib.class'
push = require 'lib.push'

-- Componentes de interface usados na demo
require 'Panel'
require 'ProgressBar'
require 'Selection'
require 'Textbox'

-- Resolução virtual (arte) e tamanho real da janela
VIRTUAL_WIDTH = 384
VIRTUAL_HEIGHT = 216
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- Cria a janela, fontes, texturas, sons e a barra
function love.load()
    love.window.setTitle('gui-1')
    math.randomseed(os.time())

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    -- Configura a tela virtual com ampliação normal
    push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = 'normal' })

    -- Fontes em três tamanhos
    gFonts = {
        ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
        ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
        ['large'] = love.graphics.newFont('fonts/font.ttf', 32)
    }

    -- Textura do cursor do menu
    gTextures = {
        ['cursor'] = love.graphics.newImage('cursor.png'),
    }

    -- Som do menu
    gSounds = {
        ['blip'] = love.audio.newSource('blip.wav', 'static'),
    }

    -- Impede iniciar um novo tween enquanto outro está em andamento
    animating = false
    -- Barra verde que começa vazia (0 de 1.0)
    pb = ProgressBar {
        x = 32, y = 32,
        width = VIRTUAL_WIDTH - 64,
        height = 16,
        value = 0,
        max = 1.0,
        color = { r = 0.2, g = 0.8, b = 0.2 },
        text = 'Progress',
        font = gFonts['medium']
    }

    love.keyboard.keysPressed = {}
end

-- Ajusta a tela virtual quando a janela é redimensionada
function love.resize(w, h)
    push.resize(w, h)
end

-- Registra a tecla pressionada; ESC fecha o jogo
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    -- Só inicia um novo tween se nenhum estiver em andamento
    if not animating then
        -- Direita: anima a barra até 100%
        if key == 'right' and pb.value < 1 then
            Timer.tween(1, {
                [pb] = { value = 1 }
            }):finish(function()
                animating = false
            end)
            animating = true
        -- Esquerda: anima a barra até 0%
        elseif key == 'left' and pb.value > 0 then
            Timer.tween(1, {
                [pb] = { value = 0 }
            }):finish(function()
                animating = false
            end)
            animating = true
        end
    end

    love.keyboard.keysPressed[key] = true
end

-- Consulta se a tecla foi pressionada neste frame
function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

-- Atualiza os tweens e a barra
function love.update(dt)
    Timer.update(dt)
    pb:update(dt)
    love.keyboard.keysPressed = {}
end

-- Desenha a barra sobre um fundo cinza
function love.draw()
    push.start()
    love.graphics.clear(0.2, 0.2, 0.2, 1)
    pb:render()
    push.finish()
end
