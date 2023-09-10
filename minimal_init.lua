local M = {}

function M.get_dir(root)
	return vim.fn.fnamemodify(root, ":p:h")
end

---@param plugin string
function M.load(plugin)
	local name = plugin:match(".*/(.*)")
	local package_root = M.get_dir(".tests/site/pack/deps/start/")
	if not vim.loop.fs_stat(package_root .. name) then
		print("Installing " .. plugin)
		vim.fn.mkdir(package_root, "p")
		vim.fn.system({
			"git",
			"clone",
			"--depth=1",
			"https://github.com/" .. plugin .. ".git",
			package_root .. "/" .. name,
		})
	end
end

function M.setup()
	vim.cmd([[set runtimepath=$VIMRUNTIME]])
	vim.opt.runtimepath:append(M.get_dir("."))
	vim.opt.packpath = { M.get_dir(".tests/site") }
	vim.env.XDG_CONFIG_HOME = M.get_dir(".tests/config")
	vim.env.XDG_DATA_HOME = M.get_dir(".tests/data")
	vim.env.XDG_STATE_HOME = M.get_dir(".tests/state")
	vim.env.XDG_CACHE_HOME = M.get_dir(".tests/cache")

	-- TODO: Pin versions of plugins?
	M.load("MunifTanjim/nui.nvim")
	M.load("nvim-lua/plenary.nvim")
end

M.setup()

return M
