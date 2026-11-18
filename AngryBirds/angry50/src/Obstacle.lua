-- Obstáculo de madeira: bloco retangular dinâmico, horizontal ou vertical.

-- Bloco que pode ser derrubado e destruído
Obstacle = Class{}

-- Escolhe quadro e dimensões conforme a orientação e cria o corpo
function Obstacle:init(world, shape, x, y)
    self.shape = shape or 'horizontal'

    -- Quadro da sprite de madeira conforme a orientação
    if self.shape == 'horizontal' then
        self.frame = 2
    elseif self.shape == 'vertical' then
        self.frame = 4
    end

    -- Posição inicial e mundo físico
    self.startX = x
    self.startY = y
    self.world = world

    -- Corpo dinâmico na posição dada (aleatória se omitida)
    self.body = love.physics.newBody(self.world,
        self.startX or math.random(VIRTUAL_WIDTH), self.startY or math.random(VIRTUAL_HEIGHT - 35), 'dynamic')
    -- Dimensões: 110x35 na horizontal, 35x110 na vertical
    if self.shape == 'horizontal' then
        self.width = 110
        self.height = 35
    elseif self.shape == 'vertical' then
        self.width = 35
        self.height = 110
    end
    -- Troca o nome da orientação pela forma física retangular
    self.shape = love.physics.newRectangleShape(self.width, self.height)

    -- O userData 'Obstacle' identifica o objeto nas colisões
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData('Obstacle')
end

-- Sem lógica própria: a física move o bloco
function Obstacle:update(dt)
end

-- Desenha a sprite centralizada no corpo, acompanhando a rotação
function Obstacle:render()
    love.graphics.draw(gTextures['wood'], gFrames['wood'][self.frame],
        self.body:getX(), self.body:getY(), self.body:getAngle(), 1, 1,
        self.width / 2, self.height / 2)
end
