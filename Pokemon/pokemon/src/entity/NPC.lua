-- Personagem não jogável que abre uma caixa de diálogo ao ser acionado.

-- Entidade que fala com o jogador
NPC = Class{__includes = Entity}

-- Chama o construtor base e define o texto do diálogo
function NPC:init(def)
    Entity.init(self, def)

    self.text = "Hi, I'm an NPC, demonstrating some dialogue! Isn't that cool??"
end

-- Empilha um DialogueState com o texto
function NPC:onInteract()
    gStateStack:push(DialogueState(self.text))
end
