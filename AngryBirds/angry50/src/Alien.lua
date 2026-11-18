-- Alienígena: corpo físico que pode ser um quadrado (alvo) ou um círculo (projétil do jogador).

-- Corpo dinâmico com formato e sprite conforme o tipo
Alien = Class{}

-- Cria o corpo físico em uma posição (aleatória se omitida)
function Alien:init(world, type, x, y, userData)
    self.world = world
    self.type = type or 'square'

    -- Corpo dinâmico: reage a gravidade e colisões
    self.body = love.physics.newBody(self.world,
        x or math.random(VIRTUAL_WIDTH), y or math.random(VIRTUAL_HEIGHT - 35),
        'dynamic')
    -- Quadrado usa uma sprite sorteada; círculo usa a sprite 9
    if self.type == 'square' then
        self.shape = love.physics.newRectangleShape(35, 35)
        self.sprite = math.random(5)
    else
        self.shape = love.physics.newCircleShape(17.5)
        self.sprite = 9
    end
    -- Fixture liga a forma ao corpo; o userData identifica o objeto nas colisões
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData(userData)
    self.launched = false
end

-- Desenha a sprite centralizada no corpo, acompanhando a rotação
function Alien:render()
    love.graphics.draw(gTextures['aliens'], gFrames['aliens'][self.sprite],
        math.floor(self.body:getX()), math.floor(self.body:getY()), self.body:getAngle(),
        1, 1, 17.5, 17.5)
end
