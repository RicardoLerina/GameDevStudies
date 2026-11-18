-- Demo gui-0: exibe um Panel, o bloco básico de interface.

-- Filtro 'nearest' mantém o pixel art nítido ao ampliar
love.graphics.setDefaultFilter('nearest', 'nearest')

-- Biblioteca de classes e escala de tela
Class = require 'lib.class'
push = require 'lib.push'

-- Componente de interface usado na demo
require 'Panel'

-- Resolução virtual (arte) e tamanho real da janela
VIRTUAL_WIDTH = 384
VIRTUAL_HEIGHT = 216
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- Cria a janela, a tela virtual e o painel
function love.load()
    love.window.setTitle('gui-0')
    math.randomseed(os.time())

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    -- Configura a tela virtual com ampliação normal
    push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = 'normal' })

    -- Painel com margem de 16 pixels em volta da tela
    panel = Panel(16, 16, VIRTUAL_WIDTH - 32, VIRTUAL_HEIGHT - 32)

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

    love.keyboard.keysPressed[key] = true
end

-- Consulta se a tecla foi pressionada neste frame
function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

-- Atualiza o painel e limpa as teclas do frame
function love.update(dt)
    panel:update(dt)
    love.keyboard.keysPressed = {}
end

-- Desenha o painel dentro da tela virtual
function love.draw()
    push.start()
    panel:render()
    push.finish()
end
