local Array = {
	__type = "Array",
}

setmetatable(Array, {
	__call = function(self, array)
		return Array.new(array)
	end,
})

Array.new = function(array)
	return setmetatable(array, { __index = Array })
end

Array.map = function(self, func)
	local result = {}
	for i, v in ipairs(self) do
		result[i] = func(v)
	end
	return Array(result)
end

return Array
