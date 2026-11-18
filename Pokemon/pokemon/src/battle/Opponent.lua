-- Oponente de uma batalha: apenas guarda o grupo de Pokémon adversário.

-- Representa o treinador/criatura adversária
Opponent = Class{}

-- Guarda o grupo de Pokémon
function Opponent:init(def)
    self.party = def.party
end

-- Reservado para a IA do oponente
function Opponent:takeTurn()

end
