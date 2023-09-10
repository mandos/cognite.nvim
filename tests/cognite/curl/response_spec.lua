local assert = require("luassert")
local Response = require("cognite.curl.response")
log = require("cognite.log").debug

describe("Response", function()
	it("should have all fields", function()
		local response = Response({
			status = 200,
			exit = 0,
			body = "body",
			headers = {},
		})
		assert.is_same(200, response.status)
		assert.is_same(0, response.exit)
		assert.is_same("body", response.body)
		assert.is_same({}, response.headers)
	end)

	it("should return values as raw table", function()
		local response = Response({
			status = 200,
			exit = 0,
			body = "response body",
			headers = {},
		})
		assert.is_same({ status = 200, exit = 0, body = "response body", headers = {} }, response._value)
	end)
end)
