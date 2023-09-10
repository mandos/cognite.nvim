local OpenAIModel = require("cognite.openai.types").OpenAIModel
local Option = require("cognite.functional.option")
local Struct = require("cognite.types.struct")
local log = require("cognite.log")

--- Cognite configuration
---@class OpenAIConfig
---@field value Option<OpenAIConfig>
---@field raw_value table
local OpenAIConfig = {}

function OpenAIConfig:create(config)
	--TODO: if config have extra fields, there is no action, consider to add validation fot this case too
	local instance = {}
	local ok, _ = pcall(vim.validate, { { config.api_key, "string", false } })
	instance.raw_value = config
	if ok then
		instance.value = Option(config)
	else
		instance.value = Option.None()
	end

	return setmetatable(instance, {
		__index = self,
		__call = function(self, config)
			return self:create(config)
		end,
	})
end

local default_config = {
	openai = {
		model = {
			model = "gpt-3.5-turbo",
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

	log.debug("full_config", full_config)

	config = {
		openai = OpenAIConfig:create(full_config.openai),
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
