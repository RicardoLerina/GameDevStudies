-- knife.bind: partial application. bind(f, a, b) returns a function that
-- calls f(a, b, ...) with any extra arguments appended.

local loadstring = _G.loadstring or _G.load
local tconcat = table.concat

-- One generated helper per argument count, reused across calls.
local helperCache = {}

-- Generates and compiles a helper specialized for argCount arguments,
-- avoiding the cost of packing/unpacking tables on every call.
local function buildHelper (argCount)
    if helperCache[argCount] then
        return helperCache[argCount]
    end
    local argList1 = { 'f' }
    local argList2 = {}
    for index = 1, argCount do
        argList1[index + 1] = 'a' .. index
        argList2[index] = 'a' .. index
    end
    argList2[argCount + 1] = '...'
    local source = 'return function(' .. tconcat(argList1, ', ') ..
        ') return function(...) return f(' .. tconcat(argList2, ', ') ..
        ') end end'
    local helper = loadstring(source)()
    helperCache[argCount] = helper
    return helper
end

return function (func, ...)
    return buildHelper(select('#', ...))(func, ...)
end
