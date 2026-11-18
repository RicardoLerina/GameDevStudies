-- Máquina de estados do jogo: troca entre a tela inicial e a partida.

-- Cria estados sob demanda a partir de uma tabela de construtores
StateMachine = Class{}

-- Recebe a tabela nome -> função construtora
function StateMachine:init(states)
	-- Estado vazio usado antes da primeira troca
	self.empty = {
		render = function() end,
		update = function() end,
		enter = function() end,
		exit = function() end
	}
	self.states = states or {}
	self.current = self.empty
end

-- Sai do estado atual e entra no novo, passando parâmetros
function StateMachine:change(stateName, enterParams)
	assert(self.states[stateName])
	self.current:exit()
	self.current = self.states[stateName]()
	self.current:enter(enterParams)
end

-- Delega o update ao estado atual
function StateMachine:update(dt)
	self.current:update(dt)
end

-- Delega o desenho ao estado atual
function StateMachine:render()
	self.current:render()
end
