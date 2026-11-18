-- Tela inicial: 100 alienígenas quicando em um mundo físico, com o título do jogo.
-- Um clique inicia a partida.

-- Menu de título com física de fundo
StartState = Class{__includes = BaseState}

-- Cria o fundo, o mundo, o chão e as paredes e os alienígenas
function StartState:init()
    self.background = Background()
    self.world = love.physics.newWorld(0, 300)

    -- Chão estático
    self.groundBody = love.physics.newBody(self.world, 0, VIRTUAL_HEIGHT, 'static')
    self.groundShape = love.physics.newEdgeShape(0, 0, VIRTUAL_WIDTH, 0)
    self.groundFixture = love.physics.newFixture(self.groundBody, self.groundShape)

    -- Paredes laterais estáticas para os alienígenas não saírem da tela
    self.leftWallBody = love.physics.newBody(self.world, 0, 0, 'static')
    self.rightWallBody = love.physics.newBody(self.world, VIRTUAL_WIDTH, 0, 'static')
    self.wallShape = love.physics.newEdgeShape(0, 0, 0, VIRTUAL_HEIGHT)
    self.leftWallFixture = love.physics.newFixture(self.leftWallBody, self.wallShape)
    self.rightWallFixture = love.physics.newFixture(self.rightWallBody, self.wallShape)
    -- Alienígenas em posições aleatórias
    self.aliens = {}
    for i = 1, 100 do
        table.insert(self.aliens, Alien(self.world))
    end
end

-- Simula a física; clique inicia o jogo e ESC sai
function StartState:update(dt)
    self.world:update(dt)
    if love.mouse.wasPressed(1) then
        gStateMachine:change('play')
    end
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

-- Desenha o fundo, os alienígenas e o título
function StartState:render()
    self.background:render()
    for k, alien in pairs(self.aliens) do
        alien:render()
    end
    -- Caixa semitransparente atrás do título
    love.graphics.setColor(64/255, 64/255, 64/255, 200/255)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 164, VIRTUAL_HEIGHT / 2 - 40,
        328, 108, 3)
    -- Título do jogo
    love.graphics.setColor(200/255, 200/255, 200/255, 1)
    love.graphics.setFont(gFonts['huge'])
    love.graphics.printf('Angry 50', 0, VIRTUAL_HEIGHT / 2 - 40, VIRTUAL_WIDTH, 'center')

    -- Instrução para iniciar
    love.graphics.setColor(200/255, 200/255, 200/255, 1)
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Click to start!', 0, VIRTUAL_HEIGHT / 2 + 40, VIRTUAL_WIDTH, 'center')
end
