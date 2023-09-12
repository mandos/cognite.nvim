local assert = require("luassert")

describe("module", function()
	describe("setup", function()
		it("should create Cognite command", function()
			require("cognite").setup({
				openai = {
					api_key = "test",
					model = {
						role = "system",
						content = "Give me ONLY correct answers",
					},
				},
			})
			assert.is_not.Nil(vim.api.nvim_get_commands({ builtin = false }).Cognite)
		end)
	end)
end)
