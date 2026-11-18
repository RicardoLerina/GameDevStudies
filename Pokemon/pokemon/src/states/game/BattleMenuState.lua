-- Menu da batalha com as opções Fight (lutar) e Run (fugir).

-- Estado que exibe o menu no canto da tela
BattleMenuState = Class{__includes = BaseState}

-- Monta o menu com as duas opções
function BattleMenuState:init(battleState)
    self.battleState = battleState
    self.battleMenu = Menu {
        x = VIRTUAL_WIDTH - 64,
        y = VIRTUAL_HEIGHT - 64,
        width = 64,
        height = 64,
        items = {
            {
                -- Lutar: sai do menu e inicia o turno
                text = 'Fight',
                onSelect = function()
                    gStateStack:pop()
                    gStateStack:push(TakeTurnState(self.battleState))
                end
            },
            {
                -- Fugir: mostra a mensagem, faz a transição e volta ao campo
                text = 'Run',
                onSelect = function()
                    gSounds['run']:play()
                    gStateStack:pop()
                    gStateStack:push(BattleMessageState('You fled successfully!',
                        function() end), false)
                    Timer.after(0.5, function()
                        gStateStack:push(FadeInState({
                            r = 1, g = 1, b = 1
                        }, 1,
                        function()
                            gSounds['field-music']:play()

                            gStateStack:pop()

                            gStateStack:pop()

                            gStateStack:push(FadeOutState({
                                r = 1, g = 1, b = 1
                            }, 1, function()
                            end))
                        end))
                    end)
                end
            }
        }
    }
end

-- Repassa a entrada ao menu
function BattleMenuState:update(dt)
    self.battleMenu:update(dt)
end

-- Desenha o menu
function BattleMenuState:render()
    self.battleMenu:render()
end
