local t = require("cognite.openai.types")
local CurlResponse = require("cognite.curl.response")
local compose = require("cognite.functional").compose
local partial = require("cognite.functional").partial
local log = require("cognite.log")

---Create request for the Open AI.
---@param model table (should be OpenAIModel)
---@param question string
---@return Request
local function generateRequest(model, question)
	local message = t.Message({
		role = "user",
		content = question,
	})
	log.debug("Generating request;", "model:", model, "message:", message)
	return t.Request(vim.tbl_extend("error", model, {
		messages = {
			message._value,
		},
	}))
end

---Send request to the Open AI.
---@param api_key string
---@param request Request
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
	log.debug("Received response;", "response:", result.status, vim.fn.json_decode(result.body))
	return result
end

---Extract answers from the Open AI response.
---@param curl_response CurlResponse
---@return string[]
local function extractAnswers(curl_response)
	local response = vim.fn.json_decode(curl_response.body)
	log.debug("Extracting answers;", "response:", response)
	return { response.choices[1].message.content }
end

---Get some answers from the AI.
---@param model OpenAIModel
---@param api_key string
---@return fun(text: string): string[])
local function askAI(api_key, model, text)
	log.debug("Asking AI;", "api_key:", api_key, "model:", model, "text:", text)
	local sendRequestWithApiKey = partial(sendRequest, api_key)
	local generateRequestForModel = partial(generateRequest, model)
	return compose(extractAnswers, sendRequestWithApiKey, generateRequestForModel)(text)
end

return {
	askAI = askAI,

	-- NOTE: _internal is only for testing purpose
	_internal = {
		generateRequest = generateRequest,
		sendRequest = sendRequest,
		extractAnswers = extractAnswers,
	},
}
