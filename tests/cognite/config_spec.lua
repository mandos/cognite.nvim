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
		config.setup()
		assert.is_not_nil(config.get("openai"))
	end)
end)

describe("OpenAIConfig", function()
	local OpenAIConfig = require("cognite.config")._internal.OpenAIConfig
	local Option = require("cognite.functional.option")

	it("should initialize with correct values", function()
		local config = OpenAIConfig:create({ api_key = "test" })
		assert.are_same({ api_key = "test" }, config.raw_value)
		assert.are_same(Option({ api_key = "test" }), config.value)
	end)

	it("should return Option.None if value is not string", function()
		local config = OpenAIConfig:create({ api_key = 1 })
		assert.are_same({ api_key = 1 }, config.raw_value)
		assert.are_same(Option.None(), config.value)
	end)
end)
