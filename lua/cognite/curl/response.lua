local Struct = require("cognite.types.struct")

--- Response type
---@class Response
---@field status number
---@field exit number
---@field body string
---@field headers table
local Response = Struct("CurlResponse", {
	status = "number",
	exit = "number",
	body = "string",
	headers = "table",
})

return Response
