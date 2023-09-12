local assert = require("luassert")
local log = require("cognite.log").debug

describe("get for Config module", function()
	it("should return error for missing config key", function()
		local config = require("cognite.config")
		assert.has_error(function()
			config.get("missing_key")
		end)
	end)

	it("should return config key", function()
		local config = require("cognite.config")
		config.setup({
			openai = {
				api_key = "test",
				model = {
					role = "system",
					content = "Give me ONLY correct answers",
				},
			},
		})
		assert.is_not_nil(config.get("openai"))
	end)
end)

describe("OpenAIConfig", function()
	it("should be initialized with minimum values", function()
		local config = require("cognite.config")
		config.setup({
			openai = {
				api_key = "test",
			},
		})
		local openai_config = config.get("openai")
		-- log("openai_config", openai_config)
		assert.are_same("test", openai_config.api_key)
		assert.is_not_nil(openai_config.model)
	end)
end)
