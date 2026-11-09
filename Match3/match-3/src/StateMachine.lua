-- StateMachine: holds one active state at a time and forwards update and
-- render to it. States are registered as factory functions by name.

StateMachine = Class{}

function StateMachine:init(states)
	-- A do-nothing state used before the first change() call.
	self.empty = {
		render = function() end,
		update = function() end,
		enter = function() end,
		exit = function() end
	}
	self.states = states or {}
	self.current = self.empty
end

-- Leaves the current state and enters a newly built one. enterParams lets
-- the caller pass data (level, score, board...) to the next state.
function StateMachine:change(stateName, enterParams)
	assert(self.states[stateName])
	self.current:exit()
	self.current = self.states[stateName]()
	self.current:enter(enterParams)
end

function StateMachine:update(dt)
	self.current:update(dt)
end

function StateMachine:render()
	self.current:render()
end
