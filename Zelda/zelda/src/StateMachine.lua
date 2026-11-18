StateMachine = Class{}

-- registers the available states
function StateMachine:init(states)
	self.empty = {
		render = function() end,
		update = function() end,
		processAI = function() end,
		enter = function() end,
		exit = function() end
	}
	self.states = states or {}
	self.current = self.empty
end

-- exits the current state and enters a new one
function StateMachine:change(stateName, enterParams)
	assert(self.states[stateName])
	self.current:exit()
	self.current = self.states[stateName]()
	self.current:enter(enterParams)
end

-- updates the current state
function StateMachine:update(dt)
	self.current:update(dt)
end

-- renders the current state
function StateMachine:render()
	self.current:render()
end

-- forwards AI processing to the current state
function StateMachine:processAI(params, dt)
	self.current:processAI(params, dt)
end
