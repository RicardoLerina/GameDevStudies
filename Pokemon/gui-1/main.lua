-- Demo gui-1: caixa de texto paginada (Textbox) com texto longo.

-- Filtro 'nearest' mantém o pixel art nítido ao ampliar
love.graphics.setDefaultFilter('nearest', 'nearest')

-- Biblioteca de classes e escala de tela
Class = require 'lib.class'
push = require 'lib.push'

-- Componentes de interface usados na demo
require 'Panel'
require 'Textbox'

-- Resolução virtual (arte) e tamanho real da janela
VIRTUAL_WIDTH = 384
VIRTUAL_HEIGHT = 216
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- Cria a janela, as fontes e a caixa de texto
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

    -- Texto longo que será dividido em páginas
    textbox = Textbox(
        32, 32, VIRTUAL_WIDTH - 64, VIRTUAL_HEIGHT - 64,
        'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?',
        gFonts['medium']
    )

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

-- Espaço/Enter avançam o texto
function love.update(dt)
    textbox:update(dt)
    love.keyboard.keysPressed = {}
end

-- Desenha a caixa de texto
function love.draw()
    push.start()
    textbox:render()
    push.finish()
end
