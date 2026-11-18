-- Estado parado: usa a animação de ficar parado voltada para a direção atual.

-- Entidade em repouso
EntityIdleState = Class{__includes = EntityBaseState}

-- Troca para a animação 'idle' da direção atual
function EntityIdleState:init(entity)
    self.entity = entity
    self.entity:changeAnimation('idle-' .. self.entity.direction)
end
