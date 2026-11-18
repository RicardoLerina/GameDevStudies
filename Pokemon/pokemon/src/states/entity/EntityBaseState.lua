-- Estado base das entidades: guarda a entidade e desenha o quadro atual da animação.

-- Base de EntityIdleState e EntityWalkState
EntityBaseState = Class{}

-- Guarda a entidade controlada pelo estado
function EntityBaseState:init(entity)
    self.entity = entity
end

-- Sem lógica por padrão
function EntityBaseState:update(dt) end

-- Sem lógica por padrão
function EntityBaseState:enter() end

-- Sem lógica por padrão
function EntityBaseState:exit() end

-- Sem IA por padrão
function EntityBaseState:processAI(params, dt) end

-- Desenha o quadro atual na posição da entidade (arredondada para evitar tremor)
function EntityBaseState:render()
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.entity.x), math.floor(self.entity.y))
end
