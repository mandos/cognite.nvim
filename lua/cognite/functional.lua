local log = require("cognite.log")

local f = {}

---Compose functions.
---@param ... any
---@return function
--TODO: verify if it isn't better way to implement it
function f.compose(...)
	local funcs = { ... }
	return function(value)
		local result = value
		for i = #funcs, 1, -1 do
			if type(funcs[i]) ~= "function" then
				error("Expected function to compose, got " .. type(funcs[i]))
			end
			result = funcs[i](result)
		end
		return result
	end
end

---Implements partial application.
---@param fun function function to partially apply
---@param ... any
---@return function
function f.partial(func, ...)
	local partialArgs = { ... }

	return function(...)
		local combinedArgs = {}

		-- NOTE: Simple solution with unpack and combine it in func doesn't work: func(unpack(partialArgs), ...)
		-- it cut off end of partialArgs. I don't know why. So solution could work for only 1 argument(?).

		-- Add partially applied arguments
		for _, arg in ipairs(partialArgs) do
			table.insert(combinedArgs, arg)
		end

		-- Add runtime arguments
		for _, arg in ipairs({ ... }) do
			table.insert(combinedArgs, arg)
		end

		-- Call the original function with combined arguments
		return func(unpack(combinedArgs))
	end
end

---@param fun function function to lift
---@param mappable nil|Mappable mappable type to lift function over
---@return function|Mappable
function f.fmap(fun, mappable)
	local partialFunc = function(mappable)
		return mappable.map(fun)(mappable)
	end
	if mappable then
		return partialFunc(mappable)
	else
		return partialFunc
	end
end

return f
