local t = require("cognite.openai.types")
local CurlResponse = require("cognite.curl.response")
local compose = require("cognite.functional").compose
local partial = require("cognite.functional").partial
local log = require("cognite.log")

---Create request for the Open AI.
---@param model table (should be OpenAIModel)
---@param conversation OpenAIMessage[]
---@return Request
local function generateRequest(model, conversation)
	-- log.debug("Generating request;", "model:", model, "conversation:", conversation)

	--TODO: it unpack every time all messages, maybe it should be a little ealire in pipeline
	local raw_messages = {}
	-- BUG: All messages are same, doesn't matter what is in conversation list
	for _, message in ipairs(conversation) do
		-- log.debug("message:", message)
		table.insert(raw_messages, #raw_messages + 1, message.__raw)
	end

	log.debug("raw_messages:", raw_messages)

	return t.Request(vim.tbl_extend("force", model, {
		messages = raw_messages,
	}))
end

---Send request to the Open AI.
---@param api_key string
---@param request Request
---@return CurlResponse
local function sendRequest(api_key, request)
	local curl = require("plenary.curl")
	local curl_request = {
		method = "POST",
		url = "https://api.openai.com/v1/chat/completions",
		-- url = "https://127.0.0.1",
		headers = {
			-- ["api-key"] = vim.g.cognite_api_key,
			["Authorization"] = "Bearer " .. api_key,
			["Content-Type"] = "application/json",
		},
		body = vim.fn.json_encode(request._fields),
	}
	log.debug("Sending request;", "request:", curl_request)
	local success, result = pcall(curl.request, curl_request)
	local result = CurlResponse(result)
	if not success then
		log.error("Failed to send request;", "error:", result)
		return
	end
	-- log.debug("Received response;", "response:", result.status, vim.fn.json_decode(result.body))
	return result
end

---Extract messages from the Open AI response.
---@param curl_response CurlResponse
---@return OpenAIMessage
-- TODO: For now it returns only first answer, but it should return all answers
local function extractMessage(curl_response)
	local response = vim.fn.json_decode(curl_response.body)
	log.debug("Extracting answers;", "response:", response)
	return t.Message(response.choices[1].message)
end

---Generate message for the Open AI.
---@param role string (should be "user" or "system")
---@param content string
---@return OpenAIMessage
local function generateMessage(role, content)
	return t.Message({
		role = role,
		content = content,
	})
end

---Extract answers from the Open AI response.
---@param message OpenAIMessage
---@return string[]
local function extractAnswers(message)
	-- log.debug("Extracting answers;", "message:", message)
	return { message.__raw.content }
end

---Create conversation with the Open AI.
---@param api_key string
---@param model OpenAIModel
---@return fun(prompt: string): string[] function to send prompt to the AI
-- NOTE: function is not pure(?), keep conversation state
local function createConversation(api_key, model)
	log.debug("Create Conversation", "api_key:", api_key, "model:", model)
	local conversation = {}

	local addToConversation = function(what_return, message)
		assert(
			what_return == "message" or what_return == "conversation",
			"return should be 'message' or 'conversation'"
		)
		log.debug("Add to conversation:", "message:", message)
		table.insert(conversation, #conversation + 1, message)
		if what_return == "message" then
			return message
		else
			return conversation
		end
	end

	if model.message then
		addToConversation("message", model.message)
		model.message = nil
	end

	local sendRequestWithApiKey = partial(sendRequest, api_key)
	local generateRequestForModel = partial(generateRequest, model)
	local generateUserMessage = partial(generateMessage, "user")

	return function(prompt)
		log.debug("Ask AI:", "prompt:", prompt)
		return compose(
			extractAnswers,
			partial(addToConversation, "message"),
			extractMessage,
			sendRequestWithApiKey,
			generateRequestForModel,
			partial(addToConversation, "conversation"),
			generateUserMessage
		)(prompt)
	end
end

return {
	createConversation = createConversation,

	-- NOTE: _internal is only for testing purpose
	_internal = {
		generateRequest = generateRequest,
		generateMessage = generateMessage,
		sendRequest = sendRequest,
		extractAnswers = extractMessage,
	},
}
