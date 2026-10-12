push = require 'push'

Class = require 'class'

-- nossa classe Paddle (raquete)
require 'Paddle'

-- nossa classe Ball (bola)
require 'Ball'

-- tamanho da nossa janela real
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- tamanho que estamos tentando emular com o push
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- velocidade de movimento da raquete
PADDLE_SPEED = 200

--[[
    Chamada apenas uma vez no início do jogo; usada para configurar
    objetos do jogo, variáveis, etc. e preparar o mundo do jogo.
]]
function love.load()
    -- define o filtro padrão do LÖVE como "nearest-neighbor" (vizinho mais
    -- próximo), o que basicamente significa que não haverá filtragem de
    -- pixels (borrão)
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- define o título da janela da aplicação
    love.window.setTitle('Pong')

    -- inicializa a semente do gerador de números aleatórios para que as
    -- chamadas a random sejam sempre aleatórias
    math.randomseed(os.time())

    -- inicializa nossas fontes de texto retrô
    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    -- configura nossos efeitos sonoros; depois, basta indexar esta tabela e
    -- chamar o método `play` de cada entrada
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        resizable = true,
        fullscreen = false,
        vsync = true
    })

    -- inicializa nossa resolução virtual, que será renderizada dentro da
    -- janela real independentemente das suas dimensões
    push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = 'normal' })

    -- inicializa as raquetes dos jogadores; deixamos globais para que possam
    -- ser acessadas por outras funções e módulos
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    -- coloca uma bola no meio da tela
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- inicializa as variáveis de pontuação
    player1Score = 0
    player2Score = 0

    -- será 1 ou 2; quem sofreu o ponto saca no turno seguinte
    servingPlayer = 1

    -- jogador que venceu a partida; só recebe um valor válido quando
    -- chegamos a esse estado do jogo
    winningPlayer = 0

    -- o estado do jogo; pode ser qualquer um dos seguintes:
    -- 1. 'start' (início do jogo, antes do primeiro saque)
    -- 2. 'serve' (aguardando uma tecla para sacar a bola)
    -- 3. 'play' (a bola está em jogo, quicando entre as raquetes)
    -- 4. 'done' (o jogo acabou, há um vencedor, pronto para reiniciar)
    gameState = 'start'
end

--[[
    Chamada sempre que as dimensões da janela mudam, por exemplo ao
    arrastar o canto inferior dela.
]]
function love.resize(w, h)
    push.resize(w, h)
end

--[[
    Chamada a cada frame, recebendo `dt` desde o último frame. `dt`
    é a abreviação de `deltaTime` e é medido em segundos.
]]
function love.update(dt)
    if gameState == 'serve' then
        -- antes de mudar para play, inicializa a velocidade da bola com
        -- base no jogador que marcou por último
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    elseif gameState == 'play' then
        -- detecta colisão da bola com as raquetes, invertendo dx se houver e
        -- aumentando-o levemente, depois alterando dy com base na posição
        -- da colisão e, por fim, tocando um efeito sonoro
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5

            -- mantém a velocidade na mesma direção, mas com valor aleatório
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            -- mantém a velocidade na mesma direção, mas com valor aleatório
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end

        -- detecta colisão com as bordas superior e inferior da tela, tocando
        -- um efeito sonoro e invertendo dy se houver
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        -- -4 para compensar o tamanho da bola
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        -- se chegarmos à borda esquerda ou direita da tela, volta para o
        -- saque e atualiza a pontuação e o jogador que vai sacar
        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()

            -- se chegamos a 10 pontos, o jogo acabou; muda o estado
            -- para done para mostrarmos a mensagem de vitória
            if player2Score == 10 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                -- coloca a bola no meio da tela, sem velocidade
                ball:reset()
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()

            if player1Score == 10 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end

    --
    -- as raquetes podem se mover independentemente do estado
    --
    -- jogador 1
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    -- jogador 2
    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    -- atualiza a bola com base em DX e DY somente no estado play;
    -- multiplica a velocidade por dt para que o movimento não dependa
    -- da taxa de quadros
    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end

--[[
    Callback que processa as teclas no momento em que são pressionadas,
    uma única vez. Não considera teclas mantidas pressionadas, o que é
    tratado por outra função (`love.keyboard.isDown`). Útil quando queremos
    que algo aconteça imediatamente, uma só vez, como ao sair do jogo.
]]
function love.keypressed(key)
    -- `key` será a tecla que este callback detectou como pressionada
    if key == 'escape' then
        -- a função que o LÖVE2D usa para encerrar a aplicação
        love.event.quit()
    -- se pressionarmos enter durante a fase start ou serve, deve
    -- passar para o próximo estado apropriado
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            -- aqui o jogo está apenas na fase de reinício, mas o saque vai
            -- para o adversário de quem venceu, por justiça!
            gameState = 'serve'

            ball:reset()

            -- zera as pontuações
            player1Score = 0
            player2Score = 0

            -- define quem saca como o oposto de quem venceu
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

--[[
    Chamada a cada frame após o update; é responsável apenas por
    desenhar todos os objetos do jogo e outros elementos na tela.
]]
function love.draw()
    -- começa a desenhar com o push, na nossa resolução virtual
    push.start()

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    -- renderiza coisas diferentes dependendo da fase do jogo
    if gameState == 'start' then
        -- mensagens da interface
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        -- mensagens da interface
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!",
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        -- nenhuma mensagem de interface durante o jogo
    elseif gameState == 'done' then
        -- mensagens da interface
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    -- mostra a pontuação antes de renderizar a bola, para que ela passe
    -- por cima do texto
    displayScore()

    player1:render()
    player2:render()
    ball:render()

    -- mostra o FPS para depuração; basta comentar para remover
    displayFPS()

    -- finaliza o desenho com o push
    push.finish()
end

--[[
    Função simples para renderizar as pontuações.
]]
function displayScore()
    -- exibição da pontuação
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50,
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
end

--[[
    Renderiza o FPS atual.
]]
function displayFPS()
    -- exibição simples do FPS em todos os estados
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255/255, 0, 255/255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(255, 255, 255, 255)
end
