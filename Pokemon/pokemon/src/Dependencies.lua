-- Carrega todas as dependências do jogo: bibliotecas, classes, estados
-- e os recursos globais (texturas, quads, fontes e sons).

-- Bibliotecas de terceiros: classes, eventos, escala de tela e timers/tweens
Class = require 'lib.class'
Event = require 'lib.knife.event'
push = require 'lib.push'
Timer = require 'lib.knife.timer'

-- Classes e dados centrais do jogo
require 'src.Animation'
require 'src.constants'
require 'src.Party'
require 'src.Pokemon'
require 'src.pokemon_defs'
require 'src.StateMachine'
require 'src.Util'

-- Elementos visuais e lógicos da batalha
require 'src.battle.BattleSprite'
require 'src.battle.Opponent'

-- Entidades do mundo (jogador e NPCs)
require 'src.entity.entity_defs'
require 'src.entity.Entity'
require 'src.entity.Player'

-- Componentes de interface
require 'src.gui.Menu'
require 'src.gui.Panel'
require 'src.gui.ProgressBar'
require 'src.gui.Selection'
require 'src.gui.Textbox'

-- Infraestrutura de estados
require 'src.states.BaseState'
require 'src.states.StateStack'

-- Estados das entidades (parado e andando)
require 'src.states.entity.EntityBaseState'
require 'src.states.entity.EntityIdleState'
require 'src.states.entity.EntityWalkState'
require 'src.states.entity.PlayerIdleState'
require 'src.states.entity.PlayerWalkState'

-- Estados do jogo (batalha, diálogo, transições, jogo e menu inicial)
require 'src.states.game.BattleState'
require 'src.states.game.BattleMenuState'
require 'src.states.game.BattleMessageState'
require 'src.states.game.DialogueState'
require 'src.states.game.FadeInState'
require 'src.states.game.FadeOutState'
require 'src.states.game.PlayState'
require 'src.states.game.StartState'
require 'src.states.game.TakeTurnState'

-- Mundo: fase, tiles e mapas de tiles
require 'src.world.Level'
require 'src.world.tile_ids'
require 'src.world.Tile'
require 'src.world.TileMap'

-- Texturas globais, acessadas pelo nome
gTextures = {
    ['tiles'] = love.graphics.newImage('graphics/sheet.png'),
    ['entities'] = love.graphics.newImage('graphics/entities.png'),
    ['cursor'] = love.graphics.newImage('graphics/cursor.png'),

    -- Sprites de frente e de costas de cada Pokémon
    ['aardart-back'] = love.graphics.newImage('graphics/pokemon/aardart-back.png'),
    ['aardart-front'] = love.graphics.newImage('graphics/pokemon/aardart-front.png'),
    ['agnite-back'] = love.graphics.newImage('graphics/pokemon/agnite-back.png'),
    ['agnite-front'] = love.graphics.newImage('graphics/pokemon/agnite-front.png'),
    ['anoleaf-back'] = love.graphics.newImage('graphics/pokemon/anoleaf-back.png'),
    ['anoleaf-front'] = love.graphics.newImage('graphics/pokemon/anoleaf-front.png'),
    ['bamboon-back'] = love.graphics.newImage('graphics/pokemon/bamboon-back.png'),
    ['bamboon-front'] = love.graphics.newImage('graphics/pokemon/bamboon-front.png'),
    ['cardiwing-back'] = love.graphics.newImage('graphics/pokemon/cardiwing-back.png'),
    ['cardiwing-front'] = love.graphics.newImage('graphics/pokemon/cardiwing-front.png'),
}

-- Quads recortados das sprite sheets
gFrames = {
    ['tiles'] = GenerateQuads(gTextures['tiles'], 16, 16),
    ['entities'] = GenerateQuads(gTextures['entities'], 16, 16)
}

-- Fontes em três tamanhos
gFonts = {
    ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
    ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
    ['large'] = love.graphics.newFont('fonts/font.ttf', 32)
}

-- Músicas e efeitos sonoros
gSounds = {
    ['field-music'] = love.audio.newSource('sounds/field_music.wav', 'static'),
    ['battle-music'] = love.audio.newSource('sounds/battle_music.mp3', 'static'),
    ['blip'] = love.audio.newSource('sounds/blip.wav', 'static'),
    ['powerup'] = love.audio.newSource('sounds/powerup.wav', 'static'),
    ['hit'] = love.audio.newSource('sounds/hit.wav', 'static'),
    ['run'] = love.audio.newSource('sounds/run.wav', 'static'),
    ['heal'] = love.audio.newSource('sounds/heal.wav', 'static'),
    ['exp'] = love.audio.newSource('sounds/exp.wav', 'static'),
    ['levelup'] = love.audio.newSource('sounds/levelup.wav', 'static'),
    ['victory-music'] = love.audio.newSource('sounds/victory.wav', 'static'),
    ['intro-music'] = love.audio.newSource('sounds/intro.mp3', 'static')
}
