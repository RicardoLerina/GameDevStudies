-- Transição inversa: revela a tela diminuindo a opacidade da cor.

-- Reduz a opacidade de 1 a 0
FadeOutState = Class{__includes = BaseState}

-- Inicia o tween e, ao final, sai da pilha e chama o callback
function FadeOutState:init(color, time, onFadeComplete)
    self.opacity = 1
    self.r = color.r
    self.g = color.g
    self.b = color.b
    self.time = time
    Timer.tween(self.time, {
        [self] = {opacity = 0}
    })
    :finish(function()
        gStateStack:pop()
        onFadeComplete()
    end)
end

-- Sem lógica: o tween faz o trabalho
function FadeOutState:update(dt)
end

-- Desenha o retângulo da cor com a opacidade atual
function FadeOutState:render()
    love.graphics.setColor(self.r, self.g, self.b, self.opacity)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    love.graphics.setColor(1, 1, 1, 1)
end
