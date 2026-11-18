-- Carrega bibliotecas, classes e os recursos globais do jogo.

-- Bibliotecas: classes, escala de tela e timers
Class = require 'lib/class'
push = require 'lib/push'
Timer = require 'lib/knife.timer'

-- Classes do jogo
require 'src/Alien'
require 'src/AlienLaunchMarker'
require 'src/Background'
require 'src/constants'
require 'src/Level'
require 'src/Obstacle'
require 'src/StateMachine'
require 'src/Util'

-- Estados do jogo
require 'src/states/BaseState'
require 'src/states/PlayState'
require 'src/states/StartState'

-- Texturas globais: fundos, alienígenas, tiles, madeira e seta
gTextures = {

    ['blue-desert'] = love.graphics.newImage('graphics/blue_desert.png'),
    ['blue-grass'] = love.graphics.newImage('graphics/blue_grass.png'),
    ['blue-land'] = love.graphics.newImage('graphics/blue_land.png'),
    ['blue-shroom'] = love.graphics.newImage('graphics/blue_shroom.png'),
    ['colored-land'] = love.graphics.newImage('graphics/colored_land.png'),
    ['colored-desert'] = love.graphics.newImage('graphics/colored_desert.png'),
    ['colored-grass'] = love.graphics.newImage('graphics/colored_grass.png'),
    ['colored-shroom'] = love.graphics.newImage('graphics/colored_shroom.png'),
    ['aliens'] = love.graphics.newImage('graphics/aliens.png'),
    ['tiles'] = love.graphics.newImage('graphics/tiles.png'),

    ['wood'] = love.graphics.newImage('graphics/wood.png'),

    ['arrow'] = love.graphics.newImage('graphics/arrow.png')
}

-- Quads recortados das sprite sheets
gFrames = {
    ['aliens'] = GenerateQuads(gTextures['aliens'], 35, 35),
    ['tiles'] = GenerateQuads(gTextures['tiles'], 35, 35),
    -- Quatro blocos de madeira: horizontais e verticais, intactos e danificados
    ['wood'] = {
        love.graphics.newQuad(0, 0, 110, 35, gTextures['wood']:getDimensions()),
        love.graphics.newQuad(0, 35, 110, 35, gTextures['wood']:getDimensions()),
        love.graphics.newQuad(320, 180, 35, 110, gTextures['wood']:getDimensions()),
        love.graphics.newQuad(355, 355, 35, 110, gTextures['wood']:getDimensions())
    }
}

-- Efeitos sonoros e música
gSounds = {
    ['break1'] = love.audio.newSource('sounds/break1.wav', 'static'),
    ['break2'] = love.audio.newSource('sounds/break2.wav', 'static'),
    ['break3'] = love.audio.newSource('sounds/break3.mp3', 'static'),
    ['break4'] = love.audio.newSource('sounds/break4.wav', 'static'),
    ['break5'] = love.audio.newSource('sounds/break5.wav', 'static'),
    ['bounce'] = love.audio.newSource('sounds/bounce.wav', 'static'),
    ['kill'] = love.audio.newSource('sounds/kill.wav', 'static'),
    ['music'] = love.audio.newSource('sounds/music.wav', 'static')
}

-- Fontes em quatro tamanhos
gFonts = {
    ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
    ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
    ['large'] = love.graphics.newFont('fonts/font.ttf', 32),
    ['huge'] = love.graphics.newFont('fonts/font.ttf', 64)
}

-- Ajuste fino do recorte da sprite do projétil
gFrames['aliens'][9]:setViewport(105.5, 35.5, 35, 34.2)
