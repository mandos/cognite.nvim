local log = require("cognite.log")

local Generic = {}

setmetatable(Generic, {
	__call = function(self, type_config)
		return Generic.new_type(type_config)
	end,
})

function Generic.new_type(config)
	local new_type = {}
	new_type.__type = config.__type
	new_type.__validate = config.__validate
	new_type.__init = function(self, value)
		if self.__validate then
			self.__validate(value)
		end
		self.__raw = value
	end

	setmetatable(new_type, {
		__call = function(self, raw_value)
			self:__init(raw_value)
			return self
		end,
	})

	log.trace("NewType:", new_type)
	return new_type
end

return Generic
