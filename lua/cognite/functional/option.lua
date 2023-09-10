local Mappable = require("cognite.functional.mappable")
local log = require("cognite.log")

---@class Option : Mappable
---@field value any | nil
---@field is_some boolean
local Option = vim.tbl_extend("force", Mappable, { __type = "Option" })

setmetatable(Option, {
	---@diagnostic disable-next-line: unused-local
	-- NOTE: implementation of pure (return) function
	__call = function(self, value)
		return Option.Some(value)
	end,
})

---@alias Option.Some Option
---@param value any
---@return Option.Some
Option.Some = function(value)
	return setmetatable({ value = value, is_some = true }, { __index = Option })
end

---@alias Option.None Option
---@return Option.None
Option.None = function()
	return setmetatable({ is_some = false }, { __index = Option })
end

Option.lift = function(func)
	return function(value)
		return Option.map(Option(func), value)
	end
end

---Implement Mappable.map
---@param self Option
---@param func function|nil function to lift
---@return Option
Option.map = function(self, func)
	if self.is_some then
		return Option(func(self.value))
	else
		return Option.None()
	end
end

Option.bind = function(self, func)
	if self.is_some then
		local status, result = pcall(func, self.value)
		if status then
			return result
		else
			return Option.None()
		end
	else
		return self
	end
end

return Option
