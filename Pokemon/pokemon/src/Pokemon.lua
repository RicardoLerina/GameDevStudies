-- Pokémon individual: estatísticas base, IVs, nível e experiência.
-- Os atributos crescem de forma aleatória a cada nível, ponderados pelos IVs.

-- Classe de um Pokémon em batalha
Pokemon = Class{}

-- Cria o Pokémon a partir de uma definição e de um nível
function Pokemon:init(def, level)
    self.name = def.name
    self.battleSpriteFront = def.battleSpriteFront
    self.battleSpriteBack = def.battleSpriteBack

    self.baseHP = def.baseHP
    self.baseAttack = def.baseAttack
    self.baseDefense = def.baseDefense
    self.baseSpeed = def.baseSpeed
    self.HPIV = def.HPIV
    self.attackIV = def.attackIV
    self.defenseIV = def.defenseIV
    self.speedIV = def.speedIV
    -- Atributos começam nos valores base e sobem com o nível
    self.HP = self.baseHP
    self.attack = self.baseAttack
    self.defense = self.baseDefense
    self.speed = self.baseSpeed
    self.level = level
    self.currentExp = 0
    -- Experiência necessária para o próximo nível
    self.expToLevel = self.level * self.level * 5 * 0.75
    -- Simula a subida de todos os níveis até o nível atual
    self:calculateStats()

    -- A vida atual começa cheia
    self.currentHP = self.HP
end

-- Aplica um aumento de status por nível já alcançado
function Pokemon:calculateStats()
    for i = 1, self.level do
        self:statsLevelUp()
    end
end

-- Sorteia uma definição de Pokémon da tabela global
function Pokemon.getRandomDef()
    return POKEMON_DEFS[POKEMON_IDS[math.random(#POKEMON_IDS)]]
end

-- Sobe os status: 3 sorteios por atributo, cada um com chance IV/6.
-- Retorna o aumento de HP, ataque, defesa e velocidade
function Pokemon:statsLevelUp()
    local HPIncrease = 0
    for j = 1, 3 do
        if math.random(6) <= self.HPIV then
            self.HP = self.HP + 1
            HPIncrease = HPIncrease + 1
        end
    end
    local attackIncrease = 0
    for j = 1, 3 do
        if math.random(6) <= self.attackIV then
            self.attack = self.attack + 1
            attackIncrease = attackIncrease + 1
        end
    end
    local defenseIncrease = 0
    for j = 1, 3 do
        if math.random(6) <= self.defenseIV then
            self.defense = self.defense + 1
            defenseIncrease = defenseIncrease + 1
        end
    end
    local speedIncrease = 0
    for j = 1, 3 do
        if math.random(6) <= self.speedIV then
            self.speed = self.speed + 1
            speedIncrease = speedIncrease + 1
        end
    end
    return HPIncrease, attackIncrease, defenseIncrease, speedIncrease
end

-- Sobe de nível, recalcula a exp necessária e devolve os aumentos
function Pokemon:levelUp()
    self.level = self.level + 1
    self.expToLevel = self.level * self.level * 5 * 0.75
    return self:statsLevelUp()
end
