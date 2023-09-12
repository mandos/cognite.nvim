local asserts = require("luassert")

describe("plugin", function()
	it("should initialize with empty table", function()
		local cognite = require("cognite")
		assert.is_not_nil(cognite.setup({
			openai = {
				api_key = "test",
				model = {
					role = "system",
					content = "Give me ONLY correct answers",
				},
			},
		}))
	end)
end)
