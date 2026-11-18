-- Fase: mundo físico Box2D com chão, alienígenas alvo e obstáculos de madeira.
-- Trata colisões, remoção de objetos destruídos e fim de partida.

-- Contém o mundo, os objetos e o marcador de lançamento
Level = Class{}

-- Cria o mundo (gravidade 300), os callbacks de colisão e os objetos
function Level:init()

    -- Mundo físico com gravidade para baixo
    self.world = love.physics.newWorld(0, 300)

    -- Corpos marcados para destruição (não podem ser removidos durante a simulação)
    self.destroyedBodies = {}

    -- Ao colidir, destrói o alvo se a velocidade de impacto for alta o bastante
    function beginContact(a, b, coll)
        local types = {}
        types[a:getUserData()] = true
        types[b:getUserData()] = true
        -- Projétil contra obstáculo: destrói o obstáculo
        if types['Obstacle'] and types['Player'] then
            local playerFixture = a:getUserData() == 'Player' and a or b
            local obstacleFixture = a:getUserData() == 'Obstacle' and a or b
            local velX, velY = playerFixture:getBody():getLinearVelocity()
            local sumVel = math.abs(velX) + math.abs(velY)
            if sumVel > 20 then
                table.insert(self.destroyedBodies, obstacleFixture:getBody())
            end
        end

        -- Obstáculo contra alienígena: destrói o alienígena
        if types['Obstacle'] and types['Alien'] then
            local obstacleFixture = a:getUserData() == 'Obstacle' and a or b
            local alienFixture = a:getUserData() == 'Alien' and a or b
            local velX, velY = obstacleFixture:getBody():getLinearVelocity()
            local sumVel = math.abs(velX) + math.abs(velY)
            if sumVel > 20 then
                table.insert(self.destroyedBodies, alienFixture:getBody())
            end
        end

        -- Projétil contra alienígena: destrói o alienígena
        if types['Player'] and types['Alien'] then
            local playerFixture = a:getUserData() == 'Player' and a or b
            local alienFixture = a:getUserData() == 'Alien' and a or b
            local velX, velY = playerFixture:getBody():getLinearVelocity()
            local sumVel = math.abs(velX) + math.abs(velY)
            if sumVel > 20 then
                table.insert(self.destroyedBodies, alienFixture:getBody())
            end
        end

        -- Projétil no chão: toca o som de quique
        if types['Player'] and types['Ground'] then
            gSounds['bounce']:stop()
            gSounds['bounce']:play()
        end
    end
    -- Callbacks não usados
    function endContact(a, b, coll)
    end
    function preSolve(a, b, coll)
    end

    function postSolve(a, b, coll, normalImpulse, tangentImpulse)

    end

    -- Registra os callbacks de colisão no mundo
    self.world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    -- Marcador de lançamento do jogador
    self.launchMarker = AlienLaunchMarker(self.world)

    -- Listas de alvos e obstáculos
    self.aliens = {}

    self.obstacles = {}

    -- Chão: uma aresta três vezes mais larga que a tela
    self.edgeShape = love.physics.newEdgeShape(0, 0, VIRTUAL_WIDTH * 3, 0)

    -- Alienígena alvo e a estrutura de madeira que o protege
    table.insert(self.aliens, Alien(self.world, 'square', VIRTUAL_WIDTH - 80, VIRTUAL_HEIGHT - TILE_SIZE - ALIEN_SIZE / 2, 'Alien'))

    table.insert(self.obstacles, Obstacle(self.world, 'vertical',
        VIRTUAL_WIDTH - 120, VIRTUAL_HEIGHT - 35 - 110 / 2))
    table.insert(self.obstacles, Obstacle(self.world, 'vertical',
        VIRTUAL_WIDTH - 35, VIRTUAL_HEIGHT - 35 - 110 / 2))
    table.insert(self.obstacles, Obstacle(self.world, 'horizontal',
        VIRTUAL_WIDTH - 80, VIRTUAL_HEIGHT - 35 - 110 - 35 / 2))
    -- Corpo estático do chão, com atrito
    self.groundBody = love.physics.newBody(self.world, -VIRTUAL_WIDTH, VIRTUAL_HEIGHT - 35, 'static')
    self.groundFixture = love.physics.newFixture(self.groundBody, self.edgeShape)
    self.groundFixture:setFriction(0.5)
    self.groundFixture:setUserData('Ground')

    -- Fundo da fase
    self.background = Background()
end

-- Passo fixo de física de 1/60 s para uma simulação estável
local FIXED_DT = 1 / 60
local accumulator = 0

-- Atualiza a mira, a física, remove destruídos e checa o fim do lançamento
function Level:update(dt)
    accumulator = accumulator + dt

    self.launchMarker:update(dt)

    while accumulator >= FIXED_DT do
        self.world:update(FIXED_DT)
        accumulator = accumulator - FIXED_DT
    end
    -- Destrói os corpos marcados durante as colisões
    for k, body in pairs(self.destroyedBodies) do
        if not body:isDestroyed() then
            body:destroy()
        end
    end
    self.destroyedBodies = {}
    -- Remove obstáculos destruídos e toca um som de quebra aleatório
    for i = #self.obstacles, 1, -1 do
        if self.obstacles[i].body:isDestroyed() then
            table.remove(self.obstacles, i)

            local soundNum = math.random(5)
            gSounds['break' .. tostring(soundNum)]:stop()
            gSounds['break' .. tostring(soundNum)]:play()
        end
    end
    -- Remove alienígenas destruídos e toca o som de morte
    for i = #self.aliens, 1, -1 do
        if self.aliens[i].body:isDestroyed() then
            table.remove(self.aliens, i)
            gSounds['kill']:stop()
            gSounds['kill']:play()
        end
    end
    -- Se o projétil saiu da tela ou parou, prepara novo lançamento; sem alvos, volta ao início
    if self.launchMarker.launched then
        local xPos, yPos = self.launchMarker.alien.body:getPosition()
        local xVel, yVel = self.launchMarker.alien.body:getLinearVelocity()

        if xPos < 0 or (math.abs(xVel) + math.abs(yVel) < 1.5) then
            self.launchMarker.alien.body:destroy()
            self.launchMarker = AlienLaunchMarker(self.world)

            if #self.aliens == 0 then
                gStateMachine:change('start')
            end
        end
    end
end

-- Desenha chão, mira, alienígenas, obstáculos e textos
function Level:render()
    -- Chão feito de tiles repetidos
    for x = -VIRTUAL_WIDTH, VIRTUAL_WIDTH * 2, 35 do
        love.graphics.draw(gTextures['tiles'], gFrames['tiles'][12], x, VIRTUAL_HEIGHT - 35)
    end
    self.launchMarker:render()
    for k, alien in pairs(self.aliens) do
        alien:render()
    end

    for k, obstacle in pairs(self.obstacles) do
        obstacle:render()
    end
    -- Instrução exibida antes do lançamento
    if not self.launchMarker.launched then
        love.graphics.setFont(gFonts['medium'])
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.printf('Click and drag circular alien to shoot!',
            0, 64, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(1, 1, 1, 1)
    end
    -- Mensagem de vitória quando não restam alvos
    if #self.aliens == 0 then
        love.graphics.setFont(gFonts['huge'])
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.printf('VICTORY', 0, VIRTUAL_HEIGHT / 2 - 32, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(1, 1, 1, 1)
    end
end
