local log = require("cognite.log").debug

local Struct = {}

setmetatable(Struct, {
	__call = function(self, struct_type, definitions)
		local custom_struct = {
			__type = struct_type,
			_def = definitions,
		}

		setmetatable(custom_struct, {
			__call = function(self, fields)
				local instance =
					vim.tbl_extend("error", custom_struct, { _fields = {}, _validations = {}, _is_valid = true })

				setmetatable(instance, {
					__index = function(self, key)
						if key == "_value" then
							return self._fields
						end

						return self._fields[key]
					end,

					__newindex = function(self, key, value)
						if self._def[key] == nil then
							error("Unknown field: " .. key)
						end

						if type(value) ~= self._def[key] then
							self._validations[key] = "is not of type " .. self._def[key]
							self._is_valid = false
						end

						self._fields[key] = value
					end,
				})

				for key, value in pairs(fields) do
					instance[key] = value
				end

				if instance._is_valid ~= true then
					local error_msg = {}
					local errors = {}
					for key, value in pairs(instance._validations) do
						table.insert(error_msg, key .. " " .. value)
						table.sort(error_msg)
					end
					error(table.concat(error_msg, "; "))
				end

				return instance
			end,
		})

		return custom_struct
	end,
})

return Struct
