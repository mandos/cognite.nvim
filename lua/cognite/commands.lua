local ui = require("cognite.ui")
local f = require("cognite.functional")
local partial = f.partial
local log = require("cognite.log")

local M = {}

---comment
---@param params table @see :h nvim_create_user_command()
local function openChat(params)
	-- BUG: not show error message
	local config = require("cognite.config")
	local askAI = require("cognite.openai.api").askAI

	local openai_conf = config.get("openai").raw_value
	local partialAskAI = partial(askAI, openai_conf.api_key, openai_conf.model)

	ui.createChat(partialAskAI)
end

function M.setup()
	vim.api.nvim_create_user_command("Cognite", openChat, {
		desc = "Cognite commands",
		nargs = "?",
	})
end

return M
