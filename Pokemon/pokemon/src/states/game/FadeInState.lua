-- Transição que escurece (ou clareia) a tela até cobri-la com uma cor.

-- Aumenta a opacidade de 0 a 1
FadeInState = Class{__includes = BaseState}

-- Inicia o tween e, ao final, sai da pilha e chama o callback
function FadeInState:init(color, time, onFadeComplete)
    self.r = color.r
    self.g = color.g
    self.b = color.b
    self.opacity = 0
    self.time = time
    Timer.tween(self.time, {
        [self] = {opacity = 1}
    })
    :finish(function()
        gStateStack:pop()
        onFadeComplete()
    end)
end

-- Desenha o retângulo da cor com a opacidade atual
function FadeInState:render()
    love.graphics.setColor(self.r, self.g, self.b, self.opacity)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    love.graphics.setColor(1, 1, 1, 1)
end
