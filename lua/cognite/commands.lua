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
	local createConversation = require("cognite.openai.api").createConversation

	local openai_conf = config.get("openai").__raw
	local chat_header = {
		"System: " .. openai_conf.model.message.__raw.content,
		"------------------------------------------------------",
	}
	local askAI = createConversation(openai_conf.api_key, openai_conf.model)
	-- BUG: looks like I change model in createConversation and I don't have anymore access to message
	ui.createChat(askAI, chat_header)
end

function M.setup()
	vim.api.nvim_create_user_command("Cognite", openChat, {
		desc = "Cognite commands",
		nargs = "?",
	})
end

return M
