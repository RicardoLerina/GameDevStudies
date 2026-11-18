-- Estado de caminhada do jogador: além de andar, sorteia encontros
-- com Pokémon selvagens na grama alta.

-- Estende EntityWalkState com a checagem de encontros
PlayerWalkState = Class{__includes = EntityWalkState}

-- Inicializa a base e a flag de encontro
function PlayerWalkState:init(entity, level)
    EntityWalkState.init(self, entity, level)
    self.encounterFound = false
end

-- Checa o encontro antes de andar; se houve, não anda
function PlayerWalkState:enter()
    self:checkForEncounter()
    if not self.encounterFound then
        self:attemptMove()
    end
end

-- 10% de chance de batalha ao pisar em grama alta
function PlayerWalkState:checkForEncounter()
    local x, y = self.entity.mapX, self.entity.mapY
    -- Só há encontro sobre tiles de grama alta
    if self.level.grassLayer.tiles[y][x].id == TILE_IDS['tall-grass'] and math.random(10) == 1 then
        self.entity:changeState('idle')
        -- Troca a música do campo pela da batalha
        gSounds['field-music']:pause()
        gSounds['battle-music']:play()

        -- Transição: tela branca, entra na batalha e clareia de volta
        gStateStack:push(
            FadeInState({
                r = 1, g = 1, b = 1,
            }, 1,
            function()
                gStateStack:push(BattleState(self.entity))
                gStateStack:push(FadeOutState({
                    r = 1, g = 1, b = 1,
                }, 1,
                function()
                end))
            end)
        )

        self.encounterFound = true
    else
        self.encounterFound = false
    end
end
