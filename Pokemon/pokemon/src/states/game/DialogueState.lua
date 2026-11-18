-- Diálogo exibido no topo da tela, usado pelos NPCs e avisos.

-- Caixa de texto com callback opcional ao fechar
DialogueState = Class{__includes = BaseState}

-- Cria a caixa de texto no topo da tela
function DialogueState:init(text, callback)
    self.textbox = Textbox(6, 6, VIRTUAL_WIDTH - 12, 64, text, gFonts['small'])
    self.callback = callback or function() end
end

-- Quando o texto acaba, chama o callback e sai da pilha
function DialogueState:update(dt)
    self.textbox:update(dt)
    if self.textbox:isClosed() then
        self.callback()
        gStateStack:pop()
    end
end

-- Desenha a caixa
function DialogueState:render()
    self.textbox:render()
end
