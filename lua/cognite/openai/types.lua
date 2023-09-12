local log = require("cognite.log")

local Struct = require("cognite.types.struct")
local Generic = require("cognite.types.generic")

---@class CompletionObject
---@field id string
---@field object string
---@field created string
---@field choices Choice[]
---@field usage Usage
local Response = {}

---@class Choice
---@field index number
---@field massage OpenAIMessage|nil should be present if delta is not
---@field delta OpenAIMessage|nil should be present if message is not
---@field finish_reason string
local Choice = {}

---@class Usage
---@field prompt_tokens number
---@field completion_tokens number
---@field total_tokens number
local Usage = {}

---@class OpenAIMessage: Generic
---@field role string
---@field content string|nil
---@field function_call FunctionCall|nil
---@field name string|nil only for Request
local Message = Generic({
	__type = "OpenAIMessage",
	__validate = function(value)
		assert(
			value.role == "user" or value.role == "assistant" or value.role == "system",
			"role must be either 'assistent', 'user', or 'system', get: " .. tostring(value.role)
		)
		assert(value.content or value.function_call, "content or function_call must be present")
		assert(
			type(value.content) == "string" or type(value.function_call) == "table",
			"content must be a string or function_call must be a table"
		)
		return value
	end,
})

---@class OpenAIConfigModel: Generic
---@field model string ID of the model to use. See the model endpoint compatibility table for details on which models work with the Chat API.
---@field message OpenAIMessage|nil The message to be fed to the model as the "prompt".
---@field temperature number|nil default 1
---@field top_p number|nil default 1
---@field n number|nil default 1
---@field presence_penalty number|nil default 0
---@field frequency_penalty number|nil default 0; Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
local ConfigModel = Generic({
	__type = "OpenAIModel",
	__validate = function(value)
		assert(value.model, "model must be present")
		assert(type(value.model) == "string", "model must be a string")
		assert(value.message, "message must be present")
		assert(type(value.message) == "table", "message must be a table")
		-- TODO: validate rest of params
	end,
	__init = function(self, value)
		self.model = value.model
		self.message = Message(value.message)
	end,
})

---@class OpenAIModel: Generic
---@field model string ID of the model to use. See the model endpoint compatibility table for details on which models work with the Chat API.
---@field temperature number|nil default 1
---@field top_p number|nil default 1
---@field n number|nil default 1
---@field presence_penalty number|nil default 0
---@field frequency_penalty number|nil default 0; Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
local OpenAIModel = Generic({
	__type = "OpenAIModel",
	__validate = function(value)
		assert(value.model, "model must be present")
		assert(type(value.model) == "string", "model must be a string")
	end,
	__init = function(self, value)
		self.model = value.model
	end,
})

---@class OpenAIConfig: Generic
---@field api_key string
---@field model OpenAIConfigModel
local Config = Generic({
	__type = "OpenAIConfig",
	__validate = function(value)
		assert(value.api_key, "api_key must be present")
		assert(type(value.api_key) == "string", "api_key must be a string")
		assert(value.model, "model must be present")
		assert(type(value.model), "table", "model have to be table")
		return value
	end,
	__init = function(self, value)
		self.api_key = value.api_key
		self.model = ConfigModel(value.model)
	end,
})

---@class FunctionCall
---@field name string
---@field arguments string
local FunctionCall = {}

---@class CompletionChunk
---@field id string
---@field object string
---@field created string
---@field choices Choice[]
---@field model number
local CompletionChunk = {}

---@class Request
---@field messages OpenAIMessage[] A list of messages comprising the conversation so far.
---@field functions table[string] A list of functions the model may generate JSON inputs for.
---@field function_call string|nil Controls how the model responds to function calls. "none" means the model does not call a function, and responds to the end-user. "auto" means the model can pick between an end-user or calling a function. Specifying a particular function via {"name":\ "my_function"} forces the model to call that function. "none" is the default when no functions are present. "auto" is the default if functions are present.
---@field stream boolean|nil default false
---@field stop string[]|nil default nil
---@field logit_bias table[string]|nil default nil; Modify the likelihood of specified tokens appearing in the completion. Accepts a json object that maps tokens (specified by their token ID in the tokenizer) to an associated bias value from -100 to 100. Mathematically, the bias is added to the logits generated by the model prior to sampling. The exact effect will vary per model, but values between -1 and 1 should decrease or increase likelihood of selection; values like -100 or 100 should result in a ban or exclusive selection of the relevant token.
---@field user string|nil default nil A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
local Request = Struct("Request", {
	model = "string",
	messages = "table",
	-- temperature = 1,
	-- top_p = 1,
	-- n = 1,
	-- stream = false,
	-- stop = nil,
	-- presence_penalty = 0,
	-- frequency_penalty = 0,
	-- ---@diagnostic disable-next-line: assign-type-mismatch
	-- logit_bias = nil,
})

return {
	OpenAIConfig = Config,
	OpenAIMessage = Message,
	OpenAIModel = OpenAIModel,

	Response = Response,
	Choice = Choice,
	Usage = Usage,
	Message = Message,
	FunctionCall = FunctionCall,
	CompletionChunk = CompletionChunk,
	Request = Request,
}
