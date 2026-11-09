-- knife.base: minimal prototype-based class system.
-- Base:extend{...} creates a subtype; calling it creates an instance
-- and runs its constructor.

return {
    extend = function (self, subtype)
        subtype = subtype or {}
        local meta = { __index = subtype }
        return setmetatable(subtype, {
            __index = self,
            __call = function (self, ...)
                local instance = setmetatable({}, meta)
                return instance, instance:constructor(...)
            end
        })
    end,
    -- Default constructor does nothing; subtypes override it.
    constructor = function () end,
}
