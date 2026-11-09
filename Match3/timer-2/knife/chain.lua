-- Returns a function that runs link number "index", giving it a
-- continuation that runs the following link.
-- knife.chain: runs asynchronous functions in sequence. Each link
-- receives a "go" callback as its first argument and calls it to
-- continue to the next link.

local function Invoker (links, index)
    return function (...)
        local link = links[index]
        if not link then
            return
        end
        local continue = Invoker(links, index + 1)
        local returned = link(continue, ...)
        -- A link may also return a function that accepts the continuation.
        if returned then
            returned(function (_, ...) continue(...) end)
        end
    end
end

return function (...)
    local links = { ... }

    -- Called with links, appends them; called with nil, starts the chain.
    local function chain (...)
        if not (...) then
            return Invoker(links, 1)(select(2, ...))
        end
        local offset = #links
        for index = 1, select('#', ...) do
            links[offset + index] = select(index, ...)
        end
        return chain
    end

    return chain
end
