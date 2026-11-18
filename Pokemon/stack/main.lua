-- Demo stack: empilha até 100 caixas de texto (popups) para mostrar como
-- funciona a pilha de estados. Só a do topo responde às teclas.

-- Filtro 'nearest' mantém o pixel art nítido ao ampliar
love.graphics.setDefaultFilter('nearest', 'nearest')

-- Bibliotecas: classes, escala de tela e timers
Class = require 'lib.class'
push = require 'lib.push'
Timer = require 'lib.knife.timer'

-- Componentes de interface e estados usados na demo
require 'Panel'
require 'Textbox'
require 'StateStack'
require 'stack.NewPopupState'

-- Resolução virtual (arte) e tamanho real da janela
VIRTUAL_WIDTH = 384
VIRTUAL_HEIGHT = 216
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- Cria a janela, as fontes e a pilha, e agenda os popups
function love.load()
    love.window.setTitle('stack')
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

    -- Pilha global de estados
    gStateStack = StateStack()
    -- Limite de popups para a pilha não crescer indefinidamente
    local popupCap = 100
    local popupCount = 0

    -- Empilha um novo popup enquanto não atingir o limite
    local function spawnPopup()
        if popupCount < popupCap then
            gStateStack:push(NewPopupState())
            popupCount = popupCount + 1
        end
    end

    -- Gera um popup a cada 0,05 segundo
    Timer.every(0.05, spawnPopup)

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

-- Atualiza timers e o estado do topo da pilha
function love.update(dt)
    Timer.update(dt)
    gStateStack:update(dt)
    love.keyboard.keysPressed = {}
end

-- Desenha todos os popups e um contador do tamanho da pilha
function love.draw()
    push.start()
    gStateStack:render()
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle('fill', 0, 0, 100, 30)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print('Stack size: ' .. tostring(#gStateStack.states), 10, 10)
    push.finish()
end
