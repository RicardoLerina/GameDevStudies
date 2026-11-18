BaseState = Class{}

-- base state constructor, nothing to set up
function BaseState:init() end
-- hook called when the state becomes active
function BaseState:enter() end
-- hook called when the state is left
function BaseState:exit() end
-- hook for per-frame logic, overridden by subclasses
function BaseState:update(dt) end
-- hook for drawing, overridden by subclasses
function BaseState:render() end
