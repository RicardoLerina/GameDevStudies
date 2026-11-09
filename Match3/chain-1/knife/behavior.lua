-- Frame table for the current state and index.
-- knife.behavior: a frame-based state machine. Each state is a list of
-- frames with a duration and an optional action; frames advance over
-- time and a frame can jump to another state through "after".

local function getCurrentFrame (behavior)
    return behavior.states[behavior.state][behavior.index]
end

-- Moves to the next frame, following "after" or looping the state.
local function advanceFrame (behavior)
    local nextState = behavior.frame.after
    local nextIndex = behavior.index + 1
    local maxIndex = #behavior.states[behavior.state]

    if nextState then
        behavior.state = nextState
        nextIndex = 1
    elseif nextIndex > maxIndex then
        nextIndex = 1
    end

    behavior.index = nextIndex
    behavior.frame = behavior:getCurrentFrame()
end

-- Runs the action of the current frame, if any.
local function performAction (behavior)
    local act = behavior.frame.action

    if act then
        act(behavior, behavior.subject)
    end
end

-- Consumes elapsed time, possibly skipping several short frames.
local function update (behavior, dt)
    behavior.elapsed = behavior.elapsed + dt

    while behavior.elapsed >= behavior.frame.duration do
        behavior.elapsed = behavior.elapsed - behavior.frame.duration
        behavior:advanceFrame()
        behavior:performAction()
    end

    return behavior
end

-- Jumps straight to a state (and optionally a frame index).
local function setState (behavior, state, index)
    behavior.state = state
    behavior.index = index or 1
    behavior.elapsed = 0
    behavior.frame = behavior:getCurrentFrame()
    behavior:performAction()
    return behavior
end

-- Creates a behavior. "subject" is passed to every action.
return function (states, subject)
    local behavior = {
        states = states,
        subject = subject,
        elapsed = 0,
        state = 'default',
        index = 1,

        getCurrentFrame = getCurrentFrame,
        advanceFrame = advanceFrame,
        performAction = performAction,

        update = update,
        setState = setState
    }

    behavior.frame = behavior:getCurrentFrame()
    behavior:performAction()

    return behavior
end
