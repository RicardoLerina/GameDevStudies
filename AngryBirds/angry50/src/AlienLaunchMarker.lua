-- Marcador de lançamento: o jogador arrasta o alienígena com o mouse para mirar,
-- vê a trajetória prevista e solta para lançá-lo.

-- Controla a mira e o disparo do projétil
AlienLaunchMarker = Class{}

-- Define a posição base do estilingue e o estado inicial
function AlienLaunchMarker:init(world)
    self.world = world

    -- Posição de repouso; shiftedX/Y é onde o jogador arrastou
    self.baseX = 90
    self.baseY = VIRTUAL_HEIGHT - 100
    self.shiftedX = self.baseX
    self.shiftedY = self.baseY
    self.aiming = false
    self.launched = false

    -- O projétil só é criado no momento do lançamento
    self.alien = nil
end

-- Trata clicar, arrastar e soltar
function AlienLaunchMarker:update(dt)

    -- Só aceita entrada antes do lançamento
    if not self.launched then

        -- Converte a posição do mouse para coordenadas da tela virtual
        local x, y = push.toGame(love.mouse.getPosition())

        -- Clicar começa a mira
        if love.mouse.wasPressed(1) and not self.launched then
            self.aiming = true
        elseif love.mouse.wasReleased(1) and self.aiming then
            self.launched = true
            -- Soltar cria o projétil, com velocidade proporcional ao quanto foi puxado
            self.alien = Alien(self.world, 'round', self.shiftedX, self.shiftedY, 'Player')
            self.alien.body:setLinearVelocity((self.baseX - self.shiftedX) * 10, (self.baseY - self.shiftedY) * 10)

            -- Quique e amortecimento de rotação do projétil
            self.alien.fixture:setRestitution(0.4)
            self.alien.body:setAngularDamping(1)
            self.aiming = false
        -- Durante a mira, limita o arrasto a 30 pixels da base
        elseif self.aiming then

            self.shiftedX = math.min(self.baseX + 30, math.max(x, self.baseX - 30))
            self.shiftedY = math.min(self.baseY + 30, math.max(y, self.baseY - 30))
        end
    end
end

-- Desenha o alienígena na mira, a trajetória prevista ou o projétil em voo
function AlienLaunchMarker:render()
    if not self.launched then
        love.graphics.draw(gTextures['aliens'], gFrames['aliens'][9],
            self.shiftedX - 17.5, self.shiftedY - 17.5)
        if self.aiming then

            -- Velocidade inicial do lançamento
            local impulseX = (self.baseX - self.shiftedX) * 10
            local impulseY = (self.baseY - self.shiftedY) * 10

            -- Simula 90 passos da trajetória, aplicando a gravidade
            local trajX, trajY = self.shiftedX, self.shiftedY
            local gravX, gravY = self.world:getGravity()
            for i = 1, 90 do
                love.graphics.setColor(255/255, 80/255, 255/255, ((255 / 24) * i) / 255)

                trajX = self.shiftedX + i * 1/60 * impulseX
                trajY = self.shiftedY + i * 1/60 * impulseY + 0.5 * (i * i + i) * gravY * 1/60 * 1/60
                -- Desenha um ponto a cada 5 passos
                if i % 5 == 0 then
                    love.graphics.circle('fill', trajX, trajY, 3)
                end
            end
        end
        love.graphics.setColor(1, 1, 1, 1)
    else
        self.alien:render()
    end
end
