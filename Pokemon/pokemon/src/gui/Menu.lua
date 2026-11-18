-- Menu completo: um painel com uma lista de seleção dentro.

-- Combina Panel e Selection
Menu = Class{}

-- Cria o painel e a seleção na mesma área
function Menu:init(def)
    self.panel = Panel(def.x, def.y, def.width, def.height)

    self.selection = Selection {
        items = def.items,
        x = def.x,
        y = def.y,
        width = def.width,
        height = def.height
    }
end

-- Repassa a entrada para a seleção
function Menu:update(dt)
    self.selection:update(dt)
end

-- Desenha o painel e depois as opções
function Menu:render()
    self.panel:render()
    self.selection:render()
end
