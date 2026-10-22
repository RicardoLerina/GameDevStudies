StateMachine = Class{}

function StateMachine:init(states)
	-- A do-nothing placeholder state, so the first change() can safely call
	-- exit() on "current" before any real state exists.
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

-- Leaves the current state, builds the new one from its factory, and passes
-- enterParams to it (for example, the score handed from PlayState to ScoreState).
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

function StateMachine:processAI(params, dt)
	self.current:processAI(params, dt)
end
