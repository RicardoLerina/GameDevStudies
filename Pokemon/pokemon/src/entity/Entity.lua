-- Entidade base do mundo (jogador e NPCs): posição, animações e máquina de estados.

-- Classe base herdada por Player e NPC
Entity = Class{}

-- Inicializa direção, animações, tamanho e posição
function Entity:init(def)
    self.direction = 'down'
    self.animations = self:createAnimations(def.animations)
    self.mapX = def.mapX
    self.mapY = def.mapY
    self.width = def.width
    self.height = def.height

    -- Converte a posição em tiles para pixels
    self.x = (self.mapX - 1) * TILE_SIZE

    -- Sobe metade da altura para os pés ficarem alinhados ao tile
    self.y = (self.mapY - 1) * TILE_SIZE - self.height / 2
end

-- Troca o estado da máquina de estados
function Entity:changeState(name)
    self.stateMachine:change(name)
end

-- Define a animação atual pelo nome
function Entity:changeAnimation(name)
    self.currentAnimation = self.animations[name]
end

-- Cria os objetos Animation a partir das definições
function Entity:createAnimations(animations)
    local animationsReturned = {}
    for k, animationDef in pairs(animations) do
        animationsReturned[k] = Animation {
            texture = animationDef.texture or 'entities',
            frames = animationDef.frames,
            interval = animationDef.interval
        }
    end
    return animationsReturned
end

-- Chamado quando o jogador interage; as subclasses sobrescrevem
function Entity:onInteract()

end

-- Repassa a IA para o estado atual
function Entity:processAI(params, dt)
    self.stateMachine:processAI(params, dt)
end

-- Atualiza animação e estado
function Entity:update(dt)
    self.currentAnimation:update(dt)
    self.stateMachine:update(dt)
end

-- Desenha via estado atual
function Entity:render()
    self.stateMachine:render()
end
