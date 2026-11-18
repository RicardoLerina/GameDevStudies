-- Pilha de estados: só o estado do topo recebe atualizações, mas todos são desenhados,
-- de baixo para cima. Permite sobrepor diálogos, menus e transições ao jogo.

-- Gerencia a ordem de atualização e desenho dos estados
StateStack = Class{}

-- Começa vazia
function StateStack:init()
    self.states = {}
end

-- Atualiza somente o estado do topo
function StateStack:update(dt)
    if #self.states == 0 then
        return
    end
    self.states[#self.states]:update(dt)
end

-- Repassa a IA somente ao estado do topo
function StateStack:processAI(params, dt)
    if #self.states == 0 then
        return
    end
    self.states[#self.states]:processAI(params, dt)
end

-- Desenha todos os estados, do mais antigo ao mais recente
function StateStack:render()
    for i, state in ipairs(self.states) do
        state:render()
    end
end

-- Remove todos os estados
function StateStack:clear()
    self.states = {}
end

-- Empilha um estado e chama seu enter
function StateStack:push(state)
    table.insert(self.states, state)
    state:enter()
end

-- Chama o exit do topo e o remove
function StateStack:pop()
    if #self.states == 0 then
        return
    end
    self.states[#self.states]:exit()
    table.remove(self.states)
end
