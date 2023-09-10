local asserts = require("luassert")
local utils = require("cognite.utils")

local function setupNotEmptyBuffer(content)
	local buf_nr = vim.api.nvim_create_buf(false, false)
	asserts.is_not_nil(buf_nr)
	local buf_content = content or { "line1", "line2" }
	vim.api.nvim_buf_set_lines(buf_nr, 0, -1, false, buf_content)
	return buf_nr
end

local function setupEmptyBuffer()
	local buf_nr = vim.api.nvim_create_buf(false, false)
	asserts.is_not_nil(buf_nr)
	return buf_nr
end

describe("helper function", function()
	describe("readBuffer", function()
		it("should read all lines from buffer and return them as a table", function()
			-- TODO: Right now it return as string, not table
			-- local buf_nr = setupNotEmptyBuffer()
			-- local lines = utils.readBuffer(buf_nr)
			-- assert.is_same({ "line1", "line2" }, lines)
		end)
	end)

	describe("appendToBuffer", function()
		it("should append lines to the new buffer", function()
			local buf_nr = setupEmptyBuffer()
			utils.appendToBuffer(buf_nr)({ "ai-line1", "ai-line2" })
			assert.is_same({ "ai-line1", "ai-line2" }, vim.api.nvim_buf_get_lines(buf_nr, 0, -1, false))
		end)

		it("should append lines to the buffer with content", function()
			local buf_nr = setupNotEmptyBuffer()
			utils.appendToBuffer(buf_nr)({ "ai-line1", "ai-line2" })
			assert.is_same(
				{ "line1", "line2", "ai-line1", "ai-line2" },
				vim.api.nvim_buf_get_lines(buf_nr, 0, -1, false)
			)
		end)

		it("should append lines after clearing the buffer", function()
			local buf_nr = setupEmptyBuffer()
			utils.clearBuffer(buf_nr)
			utils.appendToBuffer(buf_nr)({ "ai-line1", "ai-line2" })
			assert.is_same({ "ai-line1", "ai-line2" }, vim.api.nvim_buf_get_lines(buf_nr, 0, -1, false))
		end)

		it("should work with partial application", function()
			local buf_nr = setupEmptyBuffer()
			local append = utils.appendToBuffer(buf_nr)
			append({ "ai-line1", "ai-line2" })
			assert.is_same({ "ai-line1", "ai-line2" }, vim.api.nvim_buf_get_lines(buf_nr, 0, -1, false))
		end)
	end)

	describe("clearBuffer", function()
		it("should clear the buffer", function()
			local buf_nr = setupNotEmptyBuffer()
			utils.clearBuffer(buf_nr)
			-- NOTE: '' (empty sting) is good enaugh?
			assert.is_same({ "" }, vim.api.nvim_buf_get_lines(buf_nr, 0, -1, false))
		end)
	end)
end)
