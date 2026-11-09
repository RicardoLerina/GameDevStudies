-- knife.memoize: caches the results of a function by its arguments, so
-- repeated calls with the same arguments skip the computation.

local loadstring = _G.loadstring or _G.load
-- Weak keys let cached entries be collected once their keys are gone.
local weakKeys = { __mode = 'k' }
local cache = setmetatable({}, weakKeys)
-- Unique keys: one marks where results are stored, one stands for nil.
local resultsKey = {}
local nilKey = {}

local function getMetaCall (callable)
    local meta = getmetatable(callable)
    return meta and meta.__call
end

local tupleConstructorCache = {}

-- Generates a function that captures n values and returns them all,
-- preserving multiple return values (including nils).
local function buildTupleConstructor (n)
    if tupleConstructorCache[n] then
        return tupleConstructorCache[n]
    end
    local t = {}
    for i = 1, n do
        t[i] = "a" .. i
    end
    local args = table.concat(t, ',')
    local ctor = loadstring('return function(' .. args ..
        ') return function() return ' .. args .. ' end end')()
    tupleConstructorCache[n] = ctor
    return ctor
end

local function tuple (...)
    return buildTupleConstructor(select('#', ...))(...)
end

return function (callable)
    local metaCall = getMetaCall(callable)

    if type(callable) ~= 'function' and not metaCall then
        error 'Attempted to memoize a non-callable value.'
    end

    cache[callable] = setmetatable({}, weakKeys)

    -- Walks a tree of tables, one level per argument, to find or create
    -- the cache slot for this exact argument list.
    local function run (...)
        local node = cache[callable]
        local argc = select('#', ...)
        for i = 1, argc do
            local key = select(i, ...)
            if key == nil then
                key = nilKey
            end
            if not node[key] then
                node[key] = setmetatable({}, weakKeys)
            end
            node = node[key]
        end

        if not node[resultsKey] then
            node[resultsKey] = tuple(callable(...))
        end

        return node[resultsKey]()
    end

    -- For callable tables, reset the cache if their __call is replaced.
    if metaCall then
        return function (...)
            local call = getMetaCall(callable)

            if call ~= metaCall then
                cache[callable] = setmetatable({}, weakKeys)
                metaCall = call
            end

            return run(...)
        end, cache, resultsKey, nilKey
    end

    return run, cache, resultsKey, nilKey
end
