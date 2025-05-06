local M = {}
local ID = "Angular-Switcher: "
local targetMap = {
	class = ".component.ts",
	styles = ".component.scss",
	template = ".component.html",
	service = ".service.ts",
}

local function jump(to)
	print(ID .. "new target: " .. to)

	local current = vim.api.nvim_buf_get_name(0)
	print(ID .. "current: " .. current .. targetMap[to])

	if current == "" then
		return
	end -- nothing to do

	local target = current
		:gsub("%.component%.ts$", targetMap[to])
		:gsub("%.component%.scss$", targetMap[to])
		:gsub("%.component%.css$", ".component.css")
		:gsub("%.component%.html$", targetMap[to])
		:gsub("%.service%.ts$", targetMap[to])

	if target == current then
		vim.notify(ID .. "no switch required", vim.log.levels.INFO)
		return
	end

	if vim.fn.filereadable(target) == 1 then
		vim.cmd("edit " .. vim.fn.fnameescape(target))
		return
	end

	vim.notify(ID .. vim.fn.fnamemodify(target, ":t") .. " not found", vim.log.levels.WARN)
end

function M.setup(opts)
	opts = opts or {}
	local map = vim.keymap.set
	local map_opts = { noremap = true, silent = true, desc = ID }

	map("n", "<M-t>", function()
		jump("class")
	end, map_opts)
	map("n", "<M-h>", function()
		jump("template")
	end, map_opts)
	map("n", "<M-c>", function()
		jump("styles")
	end, map_opts)
	map("n", "<M-s>", function()
		jump("service")
	end, map_opts)
end

return M
