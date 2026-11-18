-- Definições das entidades: quadros e intervalos das animações de andar e ficar parado
-- em cada direção.

-- Tabela global consultada ao criar jogador e NPCs
ENTITY_DEFS = {
    -- Animações do jogador
    ['player'] = {
        animations = {
            -- Andar: ciclo de 4 quadros
            ['walk-left'] = {
                frames = {16, 17, 18, 17},
                interval = 0.15,
                texture = 'entities'
            },
            ['walk-right'] = {
                frames = {28, 29, 30, 29},
                interval = 0.15,
                texture = 'entities'
            },
            ['walk-down'] = {
                frames = {4, 5, 6, 5},
                interval = 0.15,
                texture = 'entities'
            },
            ['walk-up'] = {
                frames = {40, 41, 42, 41},
                interval = 0.15,
                texture = 'entities'
            },
            -- Parado: um único quadro por direção
            ['idle-left'] = {
                frames = {17},
                texture = 'entities'
            },
            ['idle-right'] = {
                frames = {29},
                texture = 'entities'
            },
            ['idle-down'] = {
                frames = {5},
                texture = 'entities'
            },
            ['idle-up'] = {
                frames = {41},
                texture = 'entities'
            },
        }
    },
    -- Animações dos NPCs (mesmos quadros do jogador)
    ['npc'] = {
        animations = {
            ['walk-left'] = {
                frames = {16, 17, 18, 17},
                interval = 0.15,
                texture = 'entities'
            },
            ['walk-right'] = {
                frames = {28, 29, 30, 29},
                interval = 0.15,
                texture = 'entities'
            },
            ['walk-down'] = {
                frames = {4, 5, 6, 5},
                interval = 0.15,
                texture = 'entities'
            },
            ['walk-up'] = {
                frames = {40, 41, 42, 41},
                interval = 0.15,
                texture = 'entities'
            },
            ['idle-left'] = {
                frames = {17},
                texture = 'entities'
            },
            ['idle-right'] = {
                frames = {29},
                texture = 'entities'
            },
            ['idle-down'] = {
                frames = {5},
                texture = 'entities'
            },
            ['idle-up'] = {
                frames = {41},
                texture = 'entities'
            },
        }
    }
}
