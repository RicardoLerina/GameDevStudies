-- knife.system: entity-component-system helper. Builds a function that
-- runs "process" only on entities that have the listed components.
-- Prefixes: _ passes an extra argument, ? optional, = write the return
-- value back, - must be missing, ! / ~ skip when present.

local loadstring = _G.loadstring or _G.load
local tconcat = table.concat
local type = type

-- True if value is a string that starts with the given character.
local function hasSigil (sigil, value)
    return type(value) == 'string' and sigil:byte() == value:byte()
end

return function (aspects, process)
    local args = {}
    local cond = {}
    local results = {}
    local localIndex = 0
    local choicePattern = '([^|]+)'

    -- Adds a condition that returns early depending on the aspect.
    local function suppress (aspect, condition)
        cond[#cond + 1] = 'if nil'
        for option in aspect:gmatch(choicePattern) do
            cond[#cond + 1] = condition:format(option)
        end
        cond[#cond + 1] = 'then return end'
    end

    -- Adds a local holding the component, optionally required/returned.
    local function supply (aspect, isOptional, isReturned)
        localIndex = localIndex + 1
        cond[#cond + 1] = ('local l%d = nil'):format(localIndex)
        for option in aspect:gmatch(choicePattern) do
            cond[#cond + 1] = ('or _entity[%q]'):format(option)
        end
        if not isOptional then
            cond[#cond + 1] = ('if not l%d then return end'):format(localIndex)
        end
        if isReturned then
            results[#results + 1] = ('_entity[%q]'):format(aspect)
        end
        args[#args + 1] = ('l%d'):format(localIndex)
    end

    for index = 1, #aspects do
        local aspect = aspects[index]
        if hasSigil('_', aspect) then
            args[#args + 1] = aspect
        elseif hasSigil('!', aspect) or hasSigil('~', aspect) then
            suppress(aspect:sub(2), 'or _entity[%q]')
        elseif hasSigil('-', aspect) then
            suppress(aspect:sub(2), 'or not _entity[%q]')
        elseif hasSigil('?', aspect) then
            supply(aspect:sub(2), true)
        elseif hasSigil('=', aspect) then
            supply(aspect:sub(2), false, true)
        else
            supply(aspect, false)
        end
    end

    -- The checks are compiled into real Lua code for speed.
    local source = ([[
local _aspects, _process = ...
return function (_entity, ...)
    %s
    %s _process(%s ...)
    return true
end]]):format(
        tconcat(cond, ' '),
        results[1] and (tconcat(results, ',') .. ' = ') or '',
        args[1] and (tconcat(args, ', ') .. ', ') or '')

    return loadstring(source)(aspects, process)
end
