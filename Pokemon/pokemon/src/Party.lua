-- Grupo de Pokémon pertencente a uma entidade (jogador ou oponente).

-- Contêiner da lista de Pokémon
Party = Class{}

-- Guarda os Pokémon recebidos na definição
function Party:init(def)
    self.pokemon = def.pokemon
end

-- Reservado para lógica futura
function Party:update(dt)

end

-- Reservado para desenho futuro
function Party:render()

end
