-- knife.event: a simple publish/subscribe system. Handlers for each
-- event name are kept in a doubly linked list, newest first.

local Event = {}

Event.handlers = {}

-- Unlinks a handler so it no longer receives events.
local function remove (self)
    if not self.isRegistered then
        return self
    end
    if self.prevHandler then
        self.prevHandler.nextHandler = self.nextHandler
    end
    if self.nextHandler then
        self.nextHandler.prevHandler = self.prevHandler
    end
    if Event.handlers[self.name] == self then
        Event.handlers[self.name] = self.nextHandler
    end
    self.prevHandler = nil
    self.nextHandler = nil
    self.isRegistered = false

    return self
end

-- Links a handler at the front of its event list.
local function register (self)
    if self.isRegistered then
        return self
    end
    self.nextHandler = Event.handlers[self.name]
    if self.nextHandler then
        self.nextHandler.prevHandler = self
    end
    Event.handlers[self.name] = self
    self.isRegistered = true

    return self
end

local function Handler (name, callback)
    return {
        name = name,
        callback = callback,
        isRegistered = false,
        remove = remove,
        register = register
    }
end

-- Subscribes callback to the event "name". Returns the handler so it
-- can be removed later.
function Event.on (name, callback)
    return register(Handler(name, callback))
end

-- Calls every handler of "name". A handler returning false stops the
-- dispatch and is returned to the caller.
function Event.dispatch (name, ...)
    local handler = Event.handlers[name]

    while handler do
        if handler.callback(...) == false then
            return handler
        end
        handler = handler.nextHandler
    end
end

local function isCallable (value)
    return type(value) == 'function' or
        getmetatable(value) and getmetatable(value).__call
end

-- Wraps t[key] so calling it also dispatches an event with the same
-- name, keeping the original function working.
local function hookDispatcher (t, key)
    local original = t[key]

    if isCallable(original) then
        t[key] = function (...)
            original(...)
            return Event.dispatch(key, ...)
        end
    else
        t[key] = function (...)
            return Event.dispatch(key, ...)
        end
    end
end

-- Hooks the given keys of a table (or all of them), e.g. Event.hook(love).
function Event.hook (t, keys)
    if keys then
        for _, key in ipairs(keys) do
            hookDispatcher(t, key)
        end
    else
        for key in pairs(t) do
            hookDispatcher(t, key)
        end
    end
end

return Event
