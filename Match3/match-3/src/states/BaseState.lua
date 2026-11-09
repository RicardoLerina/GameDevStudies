-- BaseState: empty implementations of every state method, so concrete
-- states only need to override the ones they use.

BaseState = Class{}

function BaseState:init() end
function BaseState:enter() end
function BaseState:exit() end
function BaseState:update(dt) end
function BaseState:render() end
