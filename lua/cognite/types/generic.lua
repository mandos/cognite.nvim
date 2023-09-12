local log = require("cognite.log")

---@class Generic
---@field __type string
---@field __raw any
---@field __validate fun(value: any): any

---Create a read-only proxy for a table
---@param instance Generic
---@return Generic
local function readOnly(instance)
	local proxy = {}
	setmetatable(proxy, {
		__index = instance,
		__newindex = function(t, k, v)
			error("Attempt to modify read-only instance")
		end,
	})
	return proxy
end

---Create a new type
---@param config table
---@return Generic
local function new_type(config)
	local new_type = {}
	new_type.__type = config.__type
	new_type.__validate = config.__validate or function(value) end
	new_type.__init = config.__init or function(self, value) end

	setmetatable(new_type, {
		__call = function(self, raw_value)
			local instance = {}
			setmetatable(instance, {
				__index = self,
			})
			-- log.debug("Generic:__call", "self:", self, "raw_value:", raw_value)
			self.__validate(raw_value)
			self.__init(instance, raw_value)
			instance.__raw = raw_value

			return readOnly(instance)
		end,
	})
	-- log.trace("NewType:", new_type)
	return new_type
end

return function(type_config)
	return new_type(type_config)
end
