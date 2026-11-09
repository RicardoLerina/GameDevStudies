-- knife.timer: delays, repeating callbacks and tweens, all driven by
-- Timer.update(dt). Timers live in groups (lists); the default group
-- is used unless another one is given.

local Timer = {}

-- Removes an item from its group in O(1) by moving the last item
-- into its slot.
local function detach (group, item)
    local index = item.index

    group[index] = group[#group]
    group[index].index = index
    group[#group] = nil
    item.groupField = nil
end

-- Adds an item to a group, leaving any group it was in before.
local function attach (group, item)
    if item.groupField then
        detach (item.groupField, item)
    end

    local index = #group + 1

    item.index = index
    group[index] = item
    item.groupField = group
    item.lastGroup = group
end

-- Timer.prior: calls the callback every frame until the cutoff.
local function updateContinuous (self, dt)
    local cutoff = self.cutoff
    local elapsed = self.elapsed + dt

    if self:callback(dt) == false or elapsed >= cutoff then
        if self.finishField then
            self:finishField(elapsed - cutoff)
        end
        self:remove()
    end

    self.elapsed = elapsed

    return
end

-- Timer.after / Timer.every: fires once per elapsed interval. The
-- loop catches up if a long frame covers several intervals.
local function updateIntermittent (self, dt)
    local duration = self.delay or self.interval
    local elapsed = self.elapsed + dt

    while elapsed >= duration do
        elapsed = elapsed - duration
        if self.limitField then
            self.limitField = self.limitField - 1
        end
        if self:callback(elapsed) == false
        or self.delay or self.limitField == 0 then
            if self.finishField then
                self:finishField(elapsed)
            end
            self:remove()
            return
        end
    end

    self.elapsed = elapsed
end

-- Timer.tween: interpolates every planned value; on completion snaps
-- to the final values and runs the finish callback.
local function updateTween (self, dt)
    local elapsed = self.elapsed + dt
    local plan = self.plan
    local duration = self.duration

    self.elapsed = elapsed

    if elapsed >= duration then
        for index = 1, #plan do
            local task = plan[index]

            task.target[task.key] = task.final
        end
        if self.finishField then
            self:finishField(elapsed - duration)
        end
        self:remove()
        return
    end

    local ease = self.easeField

    for index = 1, #plan do
        local task = plan[index]
        local target, key = task.target, task.key
        local initial, change = task.initial, task.change

        target[key] = ease(elapsed, initial, change, duration)
    end

end

local defaultGroup = {}

-- Methods available on every timer handle.
local function group (self, group)
    if not group then
        group = defaultGroup
    end

    attach(group, self)

    return self
end

local function remove (self)
    if self.groupField then
        detach(self.groupField, self)
    end

    return self
end

local function register (self)
    attach(self.lastGroup, self)

    return self
end

-- Stops an "every" timer after a number of runs.
local function limit (self, limitField)
    self.limitField = limitField

    return self
end

-- Callback run when the timer completes.
local function finish (self, finishField)
    self.finishField = finishField

    return self
end

-- Replaces the tween easing function.
local function ease (self, easeField)
    self.easeField = easeField

    return self
end

-- Turns { [object] = { field = target } } into a flat list of
-- start/end values to interpolate.
local function planTween (definition)
    local plan = {}

    for target, values in pairs(definition) do
        for key, final in pairs(values) do
            local initial = target[key]

            plan[#plan + 1] = {
                target = target,
                key = key,
                initial = initial,
                final = final,
                change = final - initial,
            }
        end
    end

    return plan
end

local function easeLinear (elapsed, initial, change, duration)
    return change * elapsed / duration + initial
end

-- Gives a new timer its shared methods and starts it.
local function initialize (timer)
    timer.elapsed = 0
    timer.group = group
    timer.remove = remove
    timer.register = register

    attach(defaultGroup, timer)

    return timer
end

-- Calls callback once after "delay" seconds.
function Timer.after (delay, callback)
    return initialize {
        delay = delay,
        callback = callback,
        update = updateIntermittent,
    }
end

-- Calls callback every "interval" seconds.
function Timer.every (interval, callback)
    return initialize {
        interval = interval,
        callback = callback,
        update = updateIntermittent,
        limit = limit,
        finish = finish,
     }
end

-- Calls callback every frame during "cutoff" seconds.
function Timer.prior (cutoff, callback)
    return initialize {
        cutoff = cutoff,
        callback = callback,
        update = updateContinuous,
        finish = finish,
    }
end

-- Animates fields of one or more tables over "duration" seconds.
function Timer.tween (duration, definition)
    return initialize {
        duration = duration,
        plan = planTween(definition),
        update = updateTween,
        easeField = easeLinear,
        ease = ease,
        finish = finish,
    }
end

-- Advances every timer in a group. Iterates backwards because timers
-- remove themselves from the list when they finish.
function Timer.update (dt, group)
    if not group then
        group = defaultGroup
    end
    for index = #group, 1, -1 do
        group[index]:update(dt)
    end
end

-- Cancels every timer in a group.
function Timer.clear (group)
    if not group then
        group = defaultGroup
    end
    for i = 1, #group do
        group[i] = nil
    end
end

Timer.defaultGroup = defaultGroup

return Timer
