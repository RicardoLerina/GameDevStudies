-- Estado de exploração: o jogador anda pelo mapa; a tecla P cura o Pokémon.

-- Contém a fase e toca a música do campo
PlayState = Class{__includes = BaseState}

-- Cria a fase e toca a música em loop
function PlayState:init()
    self.level = Level()
    gSounds['field-music']:setLooping(true)
    gSounds['field-music']:play()

    self.dialogueOpened = false
end

-- Trata a cura (tecla P) e atualiza a fase
function PlayState:update(dt)
    -- Restaura a vida e avisa o jogador com um diálogo
    if not self.dialogueOpened and love.keyboard.wasPressed('p') then

        gSounds['heal']:play()
        self.level.player.party.pokemon[1].currentHP = self.level.player.party.pokemon[1].HP
        gStateStack:push(DialogueState('Your Pokemon has been healed!',
            function()
                self.dialogueOpened = false
            end))
    end
    self.level:update(dt)
end

-- Desenha a fase
function PlayState:render()
    self.level:render()
end
