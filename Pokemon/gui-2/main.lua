-- Demo gui-2: menu de seleção (Selection) que muda a cor do fundo.

-- Filtro 'nearest' mantém o pixel art nítido ao ampliar
love.graphics.setDefaultFilter('nearest', 'nearest')

-- Biblioteca de classes e escala de tela
Class = require 'lib.class'
push = require 'lib.push'

-- Componentes de interface usados na demo
require 'Panel'
require 'Selection'
require 'Textbox'

-- Resolução virtual (arte) e tamanho real da janela
VIRTUAL_WIDTH = 384
VIRTUAL_HEIGHT = 216
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- Cria a janela, fontes, texturas, sons e o menu
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

    -- Som ao mover o cursor
    gSounds = {
        ['blip'] = love.audio.newSource('blip.wav', 'static'),
    }

    -- Opções: cada onSelect troca a cor de fundo ou encerra o jogo
    selection = Selection {
        x = 32, y = 32,
        width = VIRTUAL_WIDTH - 64,
        height = VIRTUAL_HEIGHT - 64,
        items = {
            {
                text = 'Red',
                onSelect = function()
                    bg =  {1, 0, 0}
                end
            },
            {
                text = 'Green',
                onSelect = function()
                    bg = {0, 1, 0}
                end
            },
            {
                text = 'Blue',
                onSelect = function()
                    bg = {0, 0, 1}
                end
            },
            {
                text = 'Quit',
                onSelect = function()
                    love.event.quit()
                end
            }
        }
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

    love.keyboard.keysPressed[key] = true
end

-- Consulta se a tecla foi pressionada neste frame
function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

-- Atualiza o menu
function love.update(dt)
    selection:update(dt)
    love.keyboard.keysPressed = {}
end

-- Pinta o fundo com a cor escolhida e desenha o menu
function love.draw()
    push.start()
    love.graphics.clear(bg or {0, 0, 0})
    selection:render()
    push.finish()
end
