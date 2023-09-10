--- Mappable interface
--- @class Mappable
local Mappable = {
	__type = "Mappable",
}

---Uplift function over mappable
---@param func function function to lift
---@param mappable Mappable mappable type to lift function over
---@return function
function Mappable.map(func, mappable)
	error("Not implemented")
end

return Mappable
