-- Mensagem da batalha exibida no painel inferior, com callback ao fechar.

-- Caixa de texto usada para narrar a batalha
BattleMessageState = Class{__includes = BaseState}

-- Cria a caixa; canInput = false mostra a mensagem sem aceitar teclas
function BattleMessageState:init(msg, onClose, canInput)
    self.textbox = Textbox(0, VIRTUAL_HEIGHT - 64, VIRTUAL_WIDTH, 64, msg, gFonts['medium'])

    self.onClose = onClose or function() end

    self.canInput = canInput

    -- Por padrão aceita entrada
    if self.canInput == nil then self.canInput = true end
end

-- Avança o texto e, ao fechar, sai da pilha e chama o callback
function BattleMessageState:update(dt)
    if self.canInput then
        self.textbox:update(dt)
        if self.textbox:isClosed() then
            gStateStack:pop()
            self.onClose()
        end
    end
end

-- Desenha a caixa
function BattleMessageState:render()
    self.textbox:render()
end
