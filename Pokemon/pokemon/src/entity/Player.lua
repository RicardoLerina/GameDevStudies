-- Jogador: uma entidade que carrega o grupo de Pokémon.

-- Entidade controlada pelo usuário
Player = Class{__includes = Entity}

-- Cria o grupo com um Pokémon aleatório de nível 5
function Player:init(def)
    Entity.init(self, def)
    self.party = Party {
        pokemon = {
            Pokemon(Pokemon.getRandomDef(), 5)
        }
    }
end
