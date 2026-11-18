-- Plano de fundo com rolagem horizontal infinita e tipo sorteado.

-- Nomes das texturas de fundo disponíveis
BACKGROUND_TYPES = {
    'colored-land', 'blue-desert', 'blue-grass', 'blue-land',
    'blue-shroom', 'colored-desert', 'colored-grass', 'colored-shroom'
}

-- Fundo que rola conforme as setas
Background = Class{}

-- Sorteia o fundo e guarda a largura para repetir a imagem
function Background:init()
    self.background = BACKGROUND_TYPES[math.random(#BACKGROUND_TYPES)]
    self.width = gTextures[self.background]:getWidth()
    self.xOffset = 0
end

-- Rola o fundo com as setas, em metade da velocidade do mapa (paralaxe)
function Background:update(dt)
    if love.keyboard.isDown('left') then
        self.xOffset = self.xOffset + BACKGROUND_SCROLL_X_SPEED * dt
    elseif love.keyboard.isDown('right') then
        self.xOffset = self.xOffset - BACKGROUND_SCROLL_X_SPEED * dt
    end
    -- Mantém o deslocamento dentro da largura da imagem
    self.xOffset = self.xOffset % self.width
end

-- Desenha três cópias lado a lado para cobrir a tela sem emendas
function Background:render()
    love.graphics.draw(gTextures[self.background], self.xOffset, -128)
    love.graphics.draw(gTextures[self.background], self.xOffset + self.width, -128)
    love.graphics.draw(gTextures[self.background], self.xOffset - self.width, -128)
end
