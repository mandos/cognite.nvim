local M = {}

function M.setup(user_config)
	user_config = user_config or {}
	require("cognite.config").setup(user_config)
	require("cognite.commands").setup()
	return user_config
end

return M
