-- Estado de popup: uma caixa de texto em posição e tamanho aleatórios
-- com texto lorem ipsum, usada para demonstrar a pilha de estados.

-- Dependências do estado
require 'BaseState'
require 'Textbox'

-- Valores padrão caso as globais ainda não existam
local VIRTUAL_WIDTH = VIRTUAL_WIDTH or 384
local VIRTUAL_HEIGHT = VIRTUAL_HEIGHT or 216

-- Frases de exemplo que compõem o texto dos popups
local LOREM = {
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
    'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
    'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
}

-- Junta de 2 a 5 frases sorteadas em um único texto
local function random_lorem()
    local t = {}
    local n = math.random(2, 5)
    for i = 1, n do
        table.insert(t, LOREM[math.random(#LOREM)])
    end
    return table.concat(t, ' ')
end

-- Popup que se fecha quando o texto termina
NewPopupState = Class{__includes = BaseState}

-- Sorteia tamanho, posição e texto da caixa
function NewPopupState:init()
    local w = math.random(120, 220)
    local h = math.random(40, 100)
    local x = math.random(0, VIRTUAL_WIDTH - w)
    local y = math.random(0, VIRTUAL_HEIGHT - h)
    local text = random_lorem()
    self.textbox = Textbox(x, y, w, h, text, gFonts['small'])
end

-- Avança o texto e sai da pilha quando fecha
function NewPopupState:update(dt)
    self.textbox:update(dt)

    if self.textbox:isClosed() then
        gStateStack:pop()
    end
end

-- Desenha a caixa de texto
function NewPopupState:render()
    self.textbox:render()
end

-- Informa se a caixa já foi fechada
function NewPopupState:isClosed()
    return self.textbox:isClosed()
end
