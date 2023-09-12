local oai = require("cognite.openai.types")
local OpenAIMessage, OpenAIConfig = oai.OpenAIMessage, oai.OpenAIConfig

local Option = require("cognite.functional.option")
local Struct = require("cognite.types.struct")
local log = require("cognite.log")

local default_config = {
	openai = {
		model = {
			model = "gpt-3.5-turbo",
			message = { role = "system", content = "All answers should be full of dark humor." },
		},
	},
}

---@class Config
---@field openai OpenAIConfig
local config = {}

---Setup config
---@param custom_config table|nil
---@return Config
local setup = function(custom_config)
	-- log.debug("custom_config 1", custom_config)
	local custom_config = custom_config or {}
	-- log.debug("custom_config 2", custom_config)
	local full_config = vim.tbl_deep_extend("force", default_config, custom_config)
	-- log.debug("full_config", full_config)
	config = {
		openai = OpenAIConfig(full_config.openai),
	}

	return config
end

---Return key from config
---@param key string
---@return any
local get = function(key)
	if config[key] == nil then
		error("Unknown config key: " .. key .. ". Are you sure that you set up config?")
	end
	return config[key]
end

return {
	setup = setup,
	get = get,

	_internal = {
		OpenAIConfig = OpenAIConfig,
	},
}
