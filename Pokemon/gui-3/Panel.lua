-- Painel retangular com borda branca e fundo cinza escuro,
-- base visual dos menus e caixas de texto.

-- Retângulo de interface com visibilidade alternável
Panel = Class{}

-- Guarda posição e tamanho; começa visível
function Panel:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self.visible = true
end

-- Sem lógica própria
function Panel:update(dt)
end

-- Desenha a borda branca e o interior escuro, se visível
function Panel:render()
    if self.visible then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle('fill', self.x, self.y, self.width, self.height, 3)
        love.graphics.setColor(56/255, 56/255, 56/255, 1)
        love.graphics.rectangle('fill', self.x + 2, self.y + 2, self.width - 4, self.height - 4, 3)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

-- Alterna entre visível e oculto
function Panel:toggle()
    self.visible = not self.visible
end
