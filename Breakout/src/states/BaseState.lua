-- Empty versions of every method StateMachine calls, so each state only
-- needs to define the ones it actually uses.
BaseState = Class{}

function BaseState:init() end
function BaseState:enter() end
function BaseState:exit() end
function BaseState:update(dt) end
function BaseState:render() end
