local M = {}
local ID = "Angular-Switcher: "
local fileTypesMap = {
	class = { type = "class", pattern = "%.component%.ts$", replacement = ".component.ts" },
	styles = {
		type = "styles",
		pattern = "%.component%.scss$",
		cssPattern = "%.component%.css",
		replacement = ".component.scss",
	},
	template = { type = "template", pattern = "%.component%.html$", replacement = ".component.html " },
	service = { type = "service", pattern = "%.service%.ts$", replacement = ".service.ts" },
}

local function getCurrentFileType(current)
	if current:match(fileTypesMap.class.pattern) then
		return fileTypesMap.class
	elseif current:match(fileTypesMap.styles.pattern) or current:match(fileTypesMap.styles.cssPattern) then
		return fileTypesMap.styles
	elseif current:match(fileTypesMap.template.pattern) then
		return fileTypesMap.template
	elseif current:match(fileTypesMap.service.pattern) then
		return fileTypesMap.service
	else
		return nil
	end
end

local function jump(to)
	local current = vim.api.nvim_buf_get_name(0)
	local currentFileType = getCurrentFileType(current)
	if currentFileType == nil then
		-- print(ID .. "unknown file type, aborting")
		return
	end

	-- print(ID .. "switch requested: " .. currentFileType.type .. " to " .. to)
	-- print(ID .. "current file: " .. current)

	if currentFileType.type == to then
		-- print(ID .. "no switch required")
		return
	end

	local target
	if currentFileType.type == fileTypesMap.styles.type then
		-- a switch was requested, from a styles file (*.scss or *.css) to a non styles file
		-- (on this branch we know for sure that 'to' is not "styles" because equality shortcircuited above)
		local pattern = fileTypesMap.styles.pattern
		if current:match(fileTypesMap.styles.cssPattern) then
			pattern = fileTypesMap.styles.cssPattern
		end

		target = current:gsub(pattern, fileTypesMap[to].replacement)
		if vim.fn.filereadable(target) == 1 then
			vim.cmd("edit " .. vim.fn.fnameescape(target))
		else
			vim.notify(ID .. vim.fn.fnamemodify(target, ":t") .. " not found", vim.log.levels.WARN)
		end
	else
		if to == fileTypesMap.styles.type then
			-- a switch was requested, from a non styles file to the styles file

			-- first attempt to reach *.scss file
			target = current:gsub(currentFileType.pattern, fileTypesMap.styles.replacement)
			if vim.fn.filereadable(target) == 1 then
				vim.cmd("edit " .. vim.fn.fnameescape(target))
				return
			end

			-- we found no *.scss file so we'll attempt to reach the *.css file
			target = current:gsub(currentFileType.pattern, ".component.css")
			if vim.fn.filereadable(target) == 1 then
				vim.cmd("edit " .. vim.fn.fnameescape(target))
			else
				vim.notify(ID .. vim.fn.fnamemodify(target, ":t") .. " not found", vim.log.levels.WARN)
			end
		else
			-- a switch was requested, from a non styles file to a non styles file
			target = current:gsub(currentFileType.pattern, fileTypesMap[to].replacement)
			if vim.fn.filereadable(target) == 1 then
				vim.cmd("edit " .. vim.fn.fnameescape(target))
			else
				vim.notify(ID .. vim.fn.fnamemodify(target, ":t") .. " not found", vim.log.levels.WARN)
			end
		end
	end
end

function M.setup(opts)
	opts = opts or {}
	local map = vim.keymap.set
	local map_opts = { noremap = true, silent = true, desc = ID }

	map("n", "<M-t>", function()
		jump(fileTypesMap.class.type)
	end, map_opts)
	map("n", "<M-h>", function()
		jump(fileTypesMap.template.type)
	end, map_opts)
	map("n", "<M-c>", function()
		jump(fileTypesMap.styles.type)
	end, map_opts)
	map("n", "<M-s>", function()
		jump(fileTypesMap.service.type)
	end, map_opts)
end

return M
