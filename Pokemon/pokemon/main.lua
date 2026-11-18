-- Ponto de entrada do jogo Poke50.
-- Configura a janela, a tela virtual (push) e a pilha de estados,
-- e repassa os eventos do LÖVE para o estado que estiver no topo.

-- Filtro 'nearest' mantém o pixel art nítido ao ampliar
love.graphics.setDefaultFilter('nearest', 'nearest')

-- Carrega bibliotecas, assets e todas as classes do jogo
require 'src.Dependencies'

-- Inicializa janela, resolução virtual e o estado inicial
function love.load()
    love.window.setTitle('Poke50')
    math.randomseed(os.time())
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = 'normal' })

    -- Pilha global: o estado do topo é o único que recebe update
    gStateStack = StateStack()
    gStateStack:push(StartState())
    -- Tabela que guarda as teclas pressionadas no frame atual
    love.keyboard.keysPressed = {}
end

-- Mantém a proporção da tela virtual quando a janela muda de tamanho
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

-- Atualiza timers e estados; limpa as teclas ao fim do frame
function love.update(dt)
    Timer.update(dt)
    gStateStack:update(dt)
    love.keyboard.keysPressed = {}
end

-- Desenha todos os estados da pilha dentro da tela virtual
function love.draw()
    push.start()
    gStateStack:render()
    push.finish()
end
