-- Parent class for every state. It provides empty versions of the methods the
-- StateMachine calls, so each state only overrides the ones it needs.
BaseState = Class{}

function BaseState:init() end
function BaseState:enter() end
function BaseState:exit() end
function BaseState:update(dt) end
function BaseState:render() end
