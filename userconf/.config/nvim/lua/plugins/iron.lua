local api = vim.api
local fn = vim.fn
local g = vim.g
local o = vim.o
local bo = vim.bo
local cmd = vim.cmd

vim.g.iron_map_defaults = 0
vim.g.iron_map_extended = 0

local iron = require("iron")

g.ripple_enable_mappings = 0
g.ripple_term_name = "term:// ripple"
g.ripple_repls = {
	javascript = "node",
	r = "radian",
}

local function replace_tab(str)
	return str:gsub("\t", string.rep(" ", bo.tabstop))
end

local function num_leading_spaces(str)
	local first_char = str:find("[^ ]")
	return first_char and first_char - 1 or #str
end

local function is_whitespace(str)
	return str:match([[^%s*$]])
end

local function filter(list, cb)
	local filtered = {}
	for _, el in ipairs(list) do
		if cb(el) then
			filtered[#filtered + 1] = el
		end
	end
	return filtered
end

local function transform(list, cb)
	local mapped = {}
	for _, el in ipairs(list) do
		mapped[#mapped + 1] = cb(el)
	end
	return mapped
end

local function remove_empty_lines(lines)
	return filter(lines, function(line)
		return not is_whitespace(line)
	end)
end

local function fix_indent(lines)
	local min_indent = nil
	for _, el in ipairs(lines) do
		local num_space = num_leading_spaces(el)
		min_indent = min_indent and math.min(min_indent, num_space) or num_space
	end
	return transform(lines, function(line)
		return line:sub(min_indent)
	end)
end

function SendLines(lines)
	lines = transform(lines, replace_tab)
	lines = remove_empty_lines(lines)
	lines = fix_indent(lines)
	if #lines ~= 0 then
		if #lines == 1 and (bo.ft == "python" or bo.ft == "r") then
			iron.core.send(bo.ft, { "\27[200~" .. lines[1] .. "\27[201~" })
		else
			iron.core.send(bo.ft, lines)
		end
	end
end

function SendParagraph()
	local i, c = unpack(api.nvim_win_get_cursor(0))
	local max = api.nvim_buf_line_count(0)
	local j = i
	local res = i
	local line = replace_tab(fn.getline(i))
	local indentation_of_first_line = num_leading_spaces(line)
	local last_was_empty = false
	while j < max do
		j = j + 1
		line = fn.getline(j)
		if is_whitespace(line) then
			last_was_empty = true
		else
			line = replace_tab(line)
			if last_was_empty and num_leading_spaces(line) <= indentation_of_first_line then
				break
			end
			res = j
			last_was_empty = false
		end
	end
	SendLines(fn.getline(i, res))
	fn.cursor(j < max and j or max, c + 1)
end

local function get_visual_selection()
	local line_start, column_start = unpack(fn.getpos("'<"), 2, 3)
	local line_end, column_end = unpack(fn.getpos("'>"), 2, 3)
	local lines = fn.getline(line_start, line_end)
	if #lines == 0 then
		return ""
	end
	column_end = column_end - (o.selection == "inclusive" and 0 or 1)
	lines[#lines] = lines[#lines]:sub(0, column_end)
	lines[1] = lines[1]:sub(column_start)
	return lines
end

function SendSelection()
	local lines = remove_empty_lines(get_visual_selection())
	lines = fix_indent(lines)
	SendLines(lines)
end

function SendBuffer()
	SendLines(fn.getline(0, "$"))
end

function SendLine()
	local l, c = unpack(api.nvim_win_get_cursor(0))
	local line = fn.getline(l)
	if not is_whitespace(line) then
		SendLines({ line })
	end
	pcall(api.nvim_win_set_cursor, 0, { l + 1, c })
end

function ReplOpen()
	iron.core.repl_for(bo.ft)
end

local function repl_open_cmd(buff, _)
	api.nvim_command("botright vertical split")
	api.nvim_set_current_buf(buff)

	local winnr = fn.bufwinnr(buff)
	local winid = fn.win_getid(winnr)
	api.nvim_win_set_option(winid, "winfixwidth", true)
	local timer = vim.loop.new_timer()
	timer:start(
		0,
		0,
		vim.schedule_wrap(function()
			api.nvim_buf_set_name(buff, "term://ironrepl")
		end)
	)
	return winid
end

local extend = require("iron.util.tables").extend

local format = function(open, close, cr)
	return function(lines)
		if #lines == 1 then
			return { lines[1] .. cr }
		else
			local new = { open .. lines[1] }
			for line = 2, #lines do
				table.insert(new, lines[line])
			end
			return extend(new, close)
		end
	end
end

iron.core.add_repl_definitions({
	r = {
		R = {
			command = { "R" },
			format = format("\27[200~", "\27[201~\r", "\r"),
		},
		radian = {
			command = { "radian" },
			format = format("\27[200~", "\27[201~", "\r"),
		},
	},
})

iron.core.set_config({
	preferred = require("config").repls,
	visibility = require("iron.visibility").single,
	repl_open_cmd = repl_open_cmd,
	memory_management = require("iron.scope").singleton,
})

cmd("command! ReplSendLine lua SendLine()")
cmd("command! ReplSendBuffer lua SendBuffer()")
cmd("command! ReplSendSelection lua SendSelection()")
cmd("command! ReplSendParagraph lua SendParagraph()")
cmd("command! ReplOpen lua ReplOpen()")
