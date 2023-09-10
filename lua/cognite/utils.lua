local log = require("cognite.log")

local M = {}

---Read all lines from the buffer
---@param buf_nr number
---@return string
M.readBuffer = function(buf_nr)
	local lines = vim.api.nvim_buf_get_lines(buf_nr, 0, -1, false)
	return table.concat(lines, " ")
end

---Clear the buffer
---@param buf_nr any
M.clearBuffer = function(buf_nr)
	-- TODO: consider recreating the buffer instead of clearing it (preserve the buffer's properties)
	vim.api.nvim_buf_set_lines(buf_nr, 0, -1, false, {})
end

---Split table of strings by a character
---@param tbl string[]
---@param char string
---@return string[]
M.splitTable = function(tbl, char)
	local result = {}
	log.debug("Split table;", "tbl:", tbl, "char:", char)
	for _, x in ipairs(tbl) do
		lines = vim.split(x, char)
		for _, v in ipairs(lines) do
			table.insert(result, v)
		end
	end
	log.debug("Split table;", "result:", result)
	return result
end

---Append lines to the buffer
---@param buf_nr number
---@return fun(lines: string[]):nil
M.appendToBuffer = function(buf_nr)
	local append = function(lines)
		log.debug("Lines to append", "lines:", lines)
		local last_line = vim.api.nvim_buf_line_count(buf_nr)
		local last_line_string = vim.api.nvim_buf_get_lines(buf_nr, last_line - 1, last_line, false)[1]
		-- Remove empty line at the end of the buffer (left for clearBuffer for example)
		if last_line_string == "" then
			last_line = last_line - 1
		end
		vim.api.nvim_buf_set_lines(buf_nr, last_line, -1, false, M.splitTable(lines, "\n"))
	end

	return append
end

return M
