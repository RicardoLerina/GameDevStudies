-- Animação por quadros: alterna entre os frames de uma sprite sheet
-- de acordo com um intervalo de tempo.

-- Classe que representa uma sequência de frames
Animation = Class{}

-- Recebe a definição: frames, intervalo, textura e se repete
function Animation:init(def)
    self.frames = def.frames
    self.interval = def.interval
    self.texture = def.texture
    self.looping = def.looping or true

    self.timer = 0
    self.currentFrame = 1
    self.timesPlayed = 0
end

-- Reinicia a animação do primeiro frame
function Animation:refresh()
    self.timer = 0
    self.currentFrame = 1
    self.timesPlayed = 0
end

-- Avança o frame quando o tempo acumulado passa do intervalo
function Animation:update(dt)

    -- Animações sem loop param após a primeira execução
    if not self.looping and self.timesPlayed > 0 then
        return
    end
    -- Só anima se houver mais de um frame
    if #self.frames > 1 then
        self.timer = self.timer + dt
        if self.timer > self.interval then
            self.timer = self.timer % self.interval
            self.currentFrame = math.max(1, (self.currentFrame + 1) % (#self.frames + 1))
            if self.currentFrame == 1 then
                self.timesPlayed = self.timesPlayed + 1
            end
        end
    end
end

-- Retorna o quadro (quad) atual da animação
function Animation:getCurrentFrame()
    return self.frames[self.currentFrame]
end
