-- Caixa de texto paginada: quebra o texto em linhas e exibe
-- uma página por vez a cada confirmação.

-- Painel com texto que avança por páginas
Textbox = Class{}

-- Calcula o espaçamento, quebra o texto em linhas e carrega a 1ª página
function Textbox:init(x, y, width, height, text, font)
    self.panel = Panel(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.text = text
    self.font = font or gFonts['small']
    self.padding = 8
    self.lineHeight = self.font:getHeight()
    self.linePadding = 2
    -- Quantas linhas cabem dentro do painel
    self.maxLines = math.floor((self.height - 2 * self.padding) / (self.lineHeight + self.linePadding))
    -- Quebra o texto em linhas conforme a largura disponível
    _, self.textChunks = self.font:getWrap(self.text, self.width - 2 * self.padding)

    self.chunkCounter = 1
    self.endOfText = false
    self.closed = false
    self:next()
end

-- Retorna as próximas linhas que cabem na caixa
function Textbox:nextChunks()
    local chunks = {}
    local startIdx = self.chunkCounter
    local endIdx = math.min(self.chunkCounter + self.maxLines - 1, #self.textChunks)

    for i = startIdx, endIdx do
        table.insert(chunks, self.textChunks[i])
    end
    if endIdx == #self.textChunks then
        self.endOfText = true
    else
        self.chunkCounter = endIdx + 1
    end
    return chunks
end

-- Mostra a próxima página ou fecha a caixa ao fim do texto
function Textbox:next()
    if self.endOfText then
        self.displayingChunks = {}
        self.panel:toggle()
        self.closed = true
    else
        self.displayingChunks = self:nextChunks()
    end
end

-- Espaço/Enter avançam o texto
function Textbox:update(dt)
    if love.keyboard.wasPressed('space') or love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        self:next()
    end
end

-- Informa se o texto já terminou
function Textbox:isClosed()
    return self.closed
end

-- Desenha o painel e as linhas da página atual
function Textbox:render()
    self.panel:render()
    love.graphics.setFont(self.font)
    for i = 1, #self.displayingChunks do
        love.graphics.print(
            self.displayingChunks[i],
            self.x + self.padding,
            self.y + self.padding + (i - 1) * (self.lineHeight + self.linePadding)
        )
    end
end
