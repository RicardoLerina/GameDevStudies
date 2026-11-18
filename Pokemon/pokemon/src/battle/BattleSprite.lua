-- Sprite de um Pokémon na batalha, com efeito de piscar em branco ao levar dano.

-- Desenha a textura na posição dada, com opacidade e shader
BattleSprite = Class{}

-- Guarda textura, posição e cria o shader do efeito de piscar
function BattleSprite:init(texture, x, y)
    self.texture = texture
    self.x = x
    self.y = y
    self.opacity = 1
    self.blinking = false
    -- Shader que soma branco à cor do pixel conforme WhiteFactor
    self.whiteShader = love.graphics.newShader[[
        extern float WhiteFactor;

        vec4 effect(vec4 vcolor, Image tex, vec2 texcoord, vec2 pixcoord)
        {
            vec4 outputcolor = Texel(tex, texcoord) * vcolor;
            outputcolor.rgb += vec3(WhiteFactor);
            return outputcolor;
        }
    ]]
end

-- Sem lógica própria: os Tweens externos movem a sprite
function BattleSprite:update(dt)
end

-- Aplica o shader (branco só quando está piscando) e desenha
function BattleSprite:render()
    love.graphics.setColor(1, 1, 1, self.opacity)

    love.graphics.setShader(self.whiteShader)
    self.whiteShader:send('WhiteFactor', self.blinking and 1 or 0)
    love.graphics.draw(gTextures[self.texture], self.x, self.y)
    love.graphics.setShader()
end
