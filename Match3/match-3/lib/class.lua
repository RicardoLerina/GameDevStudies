--[[
Copyright (c) 2010-2013 Matthias Richter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]

-- hump.class: a tiny class library. Class{...} builds a class table;
-- calling the class creates an instance and runs its init method.
-- Inheritance works by copying fields from tables listed in __includes.

-- Deep-copies every field of "from" into "to" that "to" does not
-- already define. "seen" prevents infinite loops on cyclic tables.
local function include_helper(to, from, seen)
	if from == nil then
		return to
	elseif type(from) ~= 'table' then
		return from
	elseif seen[from] then
		return seen[from]
	end

	seen[from] = to
	for k,v in pairs(from) do
		k = include_helper({}, k, seen)
		if to[k] == nil then
			to[k] = include_helper({}, v, seen)
		end
	end
	return to
end

-- Mixes the members of another class into this one.
local function include(class, other)
	return include_helper(class, other, {})
end

-- Returns a deep copy of an object that keeps its metatable.
local function clone(other)
	return setmetatable(include({}, other), getmetatable(other))
end

-- Builds a new class from a prototype table.
local function new(class)

	class = class or {}
	-- A single parent may be given directly instead of inside a list.
	local inc = class.__includes or {}
	if getmetatable(inc) then inc = {inc} end

	for _, other in ipairs(inc) do
		-- Parents can also be referenced by global name.
		if type(other) == "string" then
			other = _G[other]
		end
		include(class, other)
	end

	-- Instances look up missing keys (methods) on the class itself.
	class.__index = class
	class.init    = class.init    or class[1] or function() end
	class.include = class.include or include
	class.clone   = class.clone   or clone

	-- Calling the class acts as the constructor.
	return setmetatable(class, {__call = function(c, ...)
		local o = setmetatable({}, c)
		o:init(...)
		return o
	end})
end

-- Optional support for the "class commons" interop standard.
if class_commons ~= false and not common then
	common = {}
	function common.class(name, prototype, parent)
		return new{__includes = {prototype, parent}}
	end
	function common.instance(class, ...)
		return class(...)
	end
end

-- The module itself is callable: Class{...} is the same as Class.new{...}.
return setmetatable({new = new, include = include, clone = clone},
	{__call = function(_,...) return new(...) end})
