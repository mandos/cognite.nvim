local f = require("cognite.functional")
local partial = f.partial
local log = require("cognite.log")

local M = {}

local chat = require("cognite.ui").chat()

---comment
---@param params table @see :h nvim_create_user_command()
local function openChat(params)
	local chatnr = tonumber(params.fargs[1]) or 1
	log.info("Chat number: ", chatnr)

	local config = require("cognite.config")

	local openai_conf = config.get("openai")
	-- log.info("openai_conf", openai_conf.model)
	local chat_header = {
		"System: " .. openai_conf.model.message.__raw.content,
		"------------------------------------------------------",
	}

	local createConversation = require("cognite.openai.api").createConversation
	local askAI = createConversation(openai_conf.api_key, openai_conf.model)

	chat("open", chatnr, askAI, chat_header)

	-- createChat(askAI, chat_header)
	--    openChat(chatnr)
end

function M.setup()
	vim.api.nvim_create_user_command("Cognite", openChat, {
		desc = "Cognite commands",
		nargs = "?",
	})
end

return M
