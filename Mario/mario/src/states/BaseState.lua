-- BaseState: empty enter/exit/update/render so states only override what they need.

BaseState = Class{}

function BaseState:init() end
function BaseState:enter() end
function BaseState:exit() end
function BaseState:update(dt) end
function BaseState:render() end
