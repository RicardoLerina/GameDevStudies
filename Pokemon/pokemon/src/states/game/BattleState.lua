-- Estado principal da batalha: cria o oponente, as sprites e as barras de vida e experiência,
-- e conduz a animação de entrada e os diálogos iniciais.

-- Tela de batalha entre o Pokémon do jogador e um selvagem
BattleState = Class{__includes = BaseState}

-- Monta o oponente, as sprites (fora da tela) e as barras
function BattleState:init(player)
    self.player = player
    self.bottomPanel = Panel(0, VIRTUAL_HEIGHT - 64, VIRTUAL_WIDTH, 64)

    -- Indica se a animação de entrada já começou
    self.battleStarted = false
    -- Oponente com um Pokémon aleatório de nível 2 a 6
    self.opponent = Opponent {
        party = Party {
            pokemon = {
                Pokemon(Pokemon.getRandomDef(), math.random(2, 6))
            }
        }
    }
    -- Sprites começam fora da tela e deslizam para dentro
    self.playerSprite = BattleSprite(self.player.party.pokemon[1].battleSpriteBack,
        -64, VIRTUAL_HEIGHT - 128)
    self.opponentSprite = BattleSprite(self.opponent.party.pokemon[1].battleSpriteFront,
        VIRTUAL_WIDTH, 8)

    -- Barras de vida (vermelhas)
    self.playerHealthBar = ProgressBar {
        x = VIRTUAL_WIDTH - 160,
        y = VIRTUAL_HEIGHT - 80,
        width = 152,
        height = 6,
        color = {r = 189/255, g = 32/255, b = 32/255},
        value = self.player.party.pokemon[1].currentHP,
        max = self.player.party.pokemon[1].HP
    }
    self.opponentHealthBar = ProgressBar {
        x = 8,
        y = 8,
        width = 152,
        height = 6,
        color = {r = 189/255, g = 32/255, b = 32/255},
        value = self.opponent.party.pokemon[1].currentHP,
        max = self.opponent.party.pokemon[1].HP
    }
    -- Barra de experiência (azul) do jogador
    self.playerExpBar = ProgressBar {
        x = VIRTUAL_WIDTH - 160,
        y = VIRTUAL_HEIGHT - 73,
        width = 152,
        height = 6,
        color = {r = 32/255, g = 32/255, b = 189/255},
        value = self.player.party.pokemon[1].currentExp,
        max = self.player.party.pokemon[1].expToLevel
    }
    -- As barras só aparecem depois da entrada
    self.renderHealthBars = false
    -- Posição das elipses que simulam o chão sob cada Pokémon
    self.playerCircleX = -68
    self.opponentCircleX = VIRTUAL_WIDTH + 32
    self.playerPokemon = self.player.party.pokemon[1]
    self.opponentPokemon = self.opponent.party.pokemon[1]
end

-- Sem lógica ao entrar
function BattleState:enter(params)
end

-- Ao sair da batalha, para a música
function BattleState:exit()
    gSounds['battle-music']:stop()
end

-- Dispara a animação de entrada no primeiro frame
function BattleState:update(dt)
    if not self.battleStarted then
        self:triggerSlideIn()
    end
end

-- Desenha fundo, chão, sprites, barras com nível e o painel inferior
function BattleState:render()
    love.graphics.setColor(214/255, 214/255, 214/255, 1)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    love.graphics.setColor(45/255, 184/255, 45/255, 124/255)
    love.graphics.ellipse('fill', self.opponentCircleX, 60, 72, 24)
    love.graphics.ellipse('fill', self.playerCircleX, VIRTUAL_HEIGHT - 64, 72, 24)
    love.graphics.setColor(1, 1, 1, 1)
    self.opponentSprite:render()
    self.playerSprite:render()
    if self.renderHealthBars then
        self.playerHealthBar:render()
        self.opponentHealthBar:render()
        self.playerExpBar:render()

        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.setFont(gFonts['small'])
        love.graphics.print('LV ' .. tostring(self.playerPokemon.level),
            self.playerHealthBar.x, self.playerHealthBar.y - 10)
        love.graphics.print('LV ' .. tostring(self.opponentPokemon.level),
            self.opponentHealthBar.x, self.opponentHealthBar.y + 8)
        love.graphics.setFont(gFonts['medium'])
        love.graphics.setColor(1, 1, 1, 1)
    end
    self.bottomPanel:render()
end

-- Desliza sprites e elipses para a posição final; depois abre o diálogo
function BattleState:triggerSlideIn()
    self.battleStarted = true

    Timer.tween(1, {
        [self.playerSprite] = {x = 32},
        [self.opponentSprite] = {x = VIRTUAL_WIDTH - 96},
        [self] = {playerCircleX = 66, opponentCircleX = VIRTUAL_WIDTH - 70}
    })
    :finish(function()
        self:triggerStartingDialogue()
        self.renderHealthBars = true
    end)
end

-- Encadeia as mensagens 'apareceu' e 'Go!' e abre o menu da batalha
function BattleState:triggerStartingDialogue()
    gStateStack:push(BattleMessageState('A wild ' .. tostring(self.opponent.party.pokemon[1].name ..
        ' appeared!'),

    function()
        gStateStack:push(BattleMessageState('Go, ' .. tostring(self.player.party.pokemon[1].name .. '!'),
        function()
            gStateStack:push(BattleMenuState(self))
        end))
    end))
end
