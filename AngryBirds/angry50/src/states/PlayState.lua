-- Estado da partida: cria a fase e rola a câmera horizontalmente com as setas.

-- Estado de jogo com a fase atual
PlayState = Class{__includes = BaseState}

-- Cria a fase; levelTranslateX é o deslocamento da câmera
function PlayState:init()
    self.level = Level()
    self.levelTranslateX = 0
end

-- ESC sai; as setas rolam a câmera dentro dos limites do mapa
function PlayState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    -- Seta esquerda: câmera para a esquerda, até o limite
    if love.keyboard.isDown('left') then
        self.levelTranslateX = self.levelTranslateX + MAP_SCROLL_X_SPEED * dt
        if self.levelTranslateX > VIRTUAL_WIDTH then
            self.levelTranslateX = VIRTUAL_WIDTH
        else
            self.level.background:update(dt)
        end
    -- Seta direita: câmera para a direita, até o limite
    elseif love.keyboard.isDown('right') then
        self.levelTranslateX = self.levelTranslateX - MAP_SCROLL_X_SPEED * dt

        if self.levelTranslateX < -VIRTUAL_WIDTH then
            self.levelTranslateX = -VIRTUAL_WIDTH
        else
            self.level.background:update(dt)
        end
    end
    -- Atualiza a física e a lógica da fase
    self.level:update(dt)
end

-- Desenha o FPS, o fundo e a fase deslocada pela câmera
function PlayState:render()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()))
    love.graphics.setColor(255, 255, 255, 255)

    self.level.background:render()
    love.graphics.translate(math.floor(self.levelTranslateX), 0)
    self.level:render()
end
