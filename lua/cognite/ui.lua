local log = require("cognite.log").debug
local model = require("cognite.openai.api")
local cmp = require("cognite.functional").compose
local f = require("cognite.functional")
local u = require("cognite.utils")
local a = require("plenary.async")

local break_line = "------------------------------------------\n"

---@class ui
---@field chat NuiLayout|nil
local M = {
	chat = nil,
}

---Create Popup for box with responses from AI
---@param header string[]
---@return NuiPopup
local function createChatBox(header)
	local Popup = require("nui.popup")
	local chat_box = Popup({
		border = "single",
		buf_options = {
			modifiable = true,
			readonly = true,
			filetype = "markdown",
		},
	})

	u.appendToBuffer(chat_box.bufnr)(header)
	return chat_box
end

---Create Popup for box where user can input question
---@return NuiPopup
local function createPromptBox()
	local Popup = require("nui.popup")
	return Popup({
		border = { style = "double", text = { top = "prompt", bottom = "cost", bottom_align = "left" } },
		enter = true,
	})
end

---Create a chat layout with all the necessary keybindings
---@param chatBox NuiPopup
---@param promptBox NuiPopup
---@param askAI fun(question: string): string[]
---@return NuiLayout
local createChat = function(chatBox, promptBox, askAI)
	local Layout = require("nui.layout")

	local chat = Layout(
		{
			relative = "editor",
			position = {
				col = "100%",
				row = 0,
			},
			size = {
				width = "40%",
				height = "100%",
			},
		},
		Layout.Box({
			Layout.Box(chatBox, {
				size = "80%",
			}),
			Layout.Box(promptBox, { size = "20%" }),
		}, { dir = "col" })
	)

	promptBox:map("n", "<C-q>", function()
		chat:unmount()
	end, { nowait = true })

	promptBox:map("n", "q", function()
		chat:unmount()
	end, { nowait = true })

	promptBox:map("i", "<CR>", function()
		local appendToChat = u.appendToBuffer(chatBox.bufnr)
		local getRawQuestion = u.readBuffer(promptBox.bufnr)
		appendToChat({ "User: " .. getRawQuestion, break_line })
		appendToChat({ "AI: " })
		f.compose(appendToChat, askAI)(getRawQuestion)
		appendToChat({ break_line })
		u.clearBuffer(promptBox.bufnr)
	end, { nowait = true })

	return chat
end

local function updateBoxes(prompt_bufnr, chat_bufnr, askAI) end

---Create a control function for chat
---@param askAI fun(question: string): string[]
---@return NuiLayout
function M.createChat(askAI, chat_header)
	if M.chat == nil then
		M.chat = createChat(createChatBox(chat_header), createPromptBox(), askAI)
		M.chat:mount()
	end

	return M.chat
end

---Create a control function for chat
---@param chat NuiLayout
---@return fun(command: string): boolean
function M.createChatControl(chat)
	local control = function(command)
		local visible = true
		if command == "hide" or (command == "toggle" and visible == true) then
			chat:hide()
			visible = false
		elseif command == "show" or (command == "toogle" and visible == false) then
			chat:show()
			visible = true
		elseif command == "quit" then
			chat:unmount()
			visible = false
		end
		return visible
	end
	return control
end

return M
