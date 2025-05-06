-- lua/angular_switcher.lua
local M = {}

-- helper that swaps suffixes and opens the target if it exists
local function jump(to)
	local current = vim.api.nvim_buf_get_name(0)
	if current == "" then
		return
	end -- nothing to do

	local target = current
	if to == "template" then
		target = current:gsub("%.component%.ts$", ".component.html")
	elseif to == "styles" then
		target = current:gsub("%.component%.ts$", ".component.scss")
	elseif to == "service" then
		target = current
			:gsub("%.component%.ts$", ".service.ts")
			:gsub("%.component%.html$", ".service.ts")
			:gsub("%.component%.scss$", ".service.ts")
	elseif to == "class" then
		target = current
			:gsub("%.component%.html$", ".component.ts")
			:gsub("%.component%.scss$", ".component.ts")
			:gsub("%.service%.ts$", ".component.ts")
	end

	if target == current then -- replacement failed
		vim.notify("Angular-Switcher: no sibling found", vim.log.levels.WARN)
		return
	end

	if vim.fn.filereadable(target) == 1 then
		vim.cmd("edit " .. vim.fn.fnameescape(target))
	else
		vim.notify("Angular-Switcher: " .. vim.fn.fnamemodify(target, ":t") .. " not found", vim.log.levels.WARN)
	end
end

function M.setup(opts)
	opts = opts or {}
	local map = vim.keymap.set
	local map_opts = { noremap = true, silent = true, desc = "Angular-Switcher" }

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
