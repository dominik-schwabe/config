local unpack = unpack

local preview = require("user.preview")

local F = require("user.functional")
local U = require("user.utils")

local M = {}

local Job = require("plenary.job")

local function get_tmux()
  return os.getenv("TMUX")
end

local function execute(arg, opts)
  local socket = vim.split(get_tmux(), ",")[1]
  local job = Job:new({
    command = "tmux",
    args = { "-S", socket, unpack(arg) },
    enable_recordings = true,
    writer = opts.input,
  })
  if opts.sync then
    return job:sync(500)
  end
  job:start(500)
end

local function get_version()
  local version = execute({ "-V" }, { sync = true })[1]
  version = version:match("%d+.%d+")
  version = version:gmatch("%d+")
  version = F.consume(version)
  version = F.map(version, function(e)
    return tonumber(e)
  end)
  return version
end

-- local function get_buffer_names()
--   local buffers = execute({ "list-buffers", "-F", "#{buffer_name}" }, { sync = true })[1]
--   return buffers and F.consume(buffers:gmatch("([^\n]+)\n?")) or {}
-- end

-- local function sync_register(index, buffer_name)
--   vim.fn.setreg(index, execute({ "show-buffer", "-b", buffer_name }, { sync = true }))
-- end

-- local function sync_unnamed_register(buffer_name)
--   if buffer_name ~= nil and buffer_name ~= "" then
--     sync_register("@", buffer_name)
--   end
-- end

-- local function sync_registers()
--   local buffer_names = get_buffer_names()
--   local first_buffer_name = buffer_names[1] or ""
--   for i, v in ipairs(buffer_names) do
--     if i > 1 then
--       break
--     end
--     sync_register(tostring(i - 1), v)
--   end
--   sync_unnamed_register(first_buffer_name)
--   sync_register("0", execute({ "show-buffer" }, { sync = true }))
-- end

-- local function bind_key(mode, key)
--   vim.keymap.set(mode, key, function()
--     sync_registers()
--     vim.api.nvim_feedkeys(key, "nx", false)
--   end)
-- end

local redirect_to_clipboard = false
local function sync_tmux_clipboard(contents, regtype)
  local content = table.concat(contents, "\n")
  content = content .. (regtype == "V" and "\n" or "")
  if redirect_to_clipboard then
    execute({ "load-buffer", "-w", "-" }, { input = content })
  else
    execute({ "load-buffer", "-" }, { input = content })
  end
end

local function tmux_post_yank()
  sync_tmux_clipboard(vim.v.event.regcontents, vim.v.event.regtype)
end

if get_tmux() ~= nil then
  local tmux_exists, version = pcall(get_version)
  if tmux_exists then
    -- local major, minor = unpack(version)
    -- TODO: check if this line is needed
    -- local redirect_to_clipboard = major > 3 or (major == 3 and minor >= 2)
    vim.api.nvim_create_augroup("UserTmux", {})
    vim.api.nvim_create_autocmd("TextYankPost", {
      group = "UserTmux",
      callback = tmux_post_yank,
    })
    -- vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdwinEnter", "VimEnter" }, {
    --   group = "UserTmux",
    --   callback = sync_registers,
    -- })

    -- bind_key("n", '"')
    -- bind_key("n", 'p')
    -- bind_key("n", 'P')

    -- vim.g.clipboard = {
    --   name = "tmuxclipboard",
    --   copy = {
    --     ["+"] = "tmux load-buffer -w -",
    --     ["*"] = "tmux load-buffer -w -",
    --   },
    --   paste = {
    --     ["+"] = "tmux save-buffer -",
    --     ["*"] = "tmux save-buffer -",
    --   },
    -- }
    -- return { sync_registers = sync_registers }
  end
end

local history_size = 50
local upper_length_limit = 1024 * 1024
local lower_length_limit = 3

local histories = {
  yank = {
    entries = {},
    pos = 0,
  },
  macro = {
    entries = {},
    pos = 0,
  },
}

local function entry_length(entry)
  return F.sum(F.map(entry.contents, function(content)
    return #content
  end))
end

local function content_is_same(contents1, contents2)
  if #contents1 ~= #contents2 then
    return false
  end
  for i, v in ipairs(contents1) do
    if v ~= contents2[i] then
      return false
    end
  end
  return true
end

local function get_default_register()
  local clipboard_flags = vim.opt.clipboard:get()
  if F.contains(clipboard_flags, "unnamedplus") then
    return "+"
  elseif F.contains(clipboard_flags, "unnamed") then
    return "*"
  end
  return '"'
end

local function entries_are_same(entry1, entry2)
  return entry1.regtype == entry2.regtype and content_is_same(entry1.contents, entry2.contents)
end

local function filter(entry)
  local length = entry_length(entry)
  if entry.regtype == "v" and length <= lower_length_limit then
    return false
  end
  if upper_length_limit < length then
    return false
  end
  return true
end

local function prune_history(entries, pos)
  if pos ~= #entries then
    local element = entries[pos]
    while pos < #entries do
      entries[pos] = entries[pos + 1]
      pos = pos + 1
    end
    entries[pos] = element
  end
  if #entries >= history_size then
    entries = F.slice(entries, #entries - history_size + 2)
  end
  return entries
end

local function is_present(history, entry)
  return history.pos ~= 0 and entries_are_same(entry, history.entries[history.pos])
end

local function add_entry_to_histroy(history, entry)
  if not is_present(history, entry) then
    local entries = prune_history(history.entries, history.pos)
    entries[#entries + 1] = entry
    history.entries = entries
    history.pos = #history.entries
  end
end

function M.add_entry_to_yank_history(entry)
  if filter(entry) then
    add_entry_to_histroy(histories.yank, entry)
  end
end

function M.add_entry_to_macro_history(entry)
  add_entry_to_histroy(histories.macro, entry)
end

local function get_register(register)
  return {
    regtype = vim.fn.getregtype(register),
    contents = vim.fn.getreg(register, 1, true),
  }
end

local function add_default_register_to_history()
  M.add_entry_to_yank_history(get_register(get_default_register()))
end

local function handle_yank_post(args)
  local event = vim.v.event
  M.add_entry_to_yank_history({
    regtype = event.regtype,
    contents = event.regcontents,
    filetype = vim.api.nvim_buf_get_option(args.buf, "filetype"),
  })
end

local function handle_macro_post()
  M.add_entry_to_macro_history({
    regtype = "v",
    contents = { vim.v.event.regcontents },
  })
end

local function set_register(register_name, entry)
  local register = get_default_register()
  vim.fn.setreg(register_name, entry.contents, entry.regtype)
  sync_tmux_clipboard(vim.fn.getreg(register, 1, true), vim.fn.getregtype(register))
end

local function num_leading_spaces(str)
  local first_char = str:find("[^ ]")
  return first_char and first_char or #str
end

local function replace_tab(str)
  return str:gsub("\t", string.rep(" ", vim.bo.tabstop))
end

local function replace_tabs(lines)
  return F.map(lines, replace_tab)
end

local function is_whitespace(str)
  return str:match([[^%s*$]])
end

local function remove_empty_lines(lines)
  return F.filter(lines, function(str)
    return not is_whitespace(str)
  end)
end

local function fix_indent(lines)
  local min_indent = F.min(F.map(remove_empty_lines(lines), num_leading_spaces))
  return F.map(lines, function(line)
    return line:sub(min_indent)
  end)
end

local function preprocess(lines)
  lines = replace_tabs(lines)
  lines = fix_indent(lines)
  return lines
end

local function cycle(direction, history, history_type, register, add_to_history, opts)
  opts = opts or {}
  add_to_history(get_register(register))
  local should_preprocess = opts.should_preprocess == nil and true or opts.should_preprocess
  local entries = history.entries
  if history.pos == 0 then
    vim.notify(history_type .. " history is empty")
    return
  end
  local current_entry = {
    regtype = vim.fn.getregtype(register),
    contents = vim.fn.getreg(register, 1, true),
  }
  if entries_are_same(current_entry, entries[history.pos]) then
    history.pos = U.clip(history.pos + direction, 1, #entries)
  end
  local entry = entries[history.pos]
  set_register(register, entry)
  local contents = entry.contents
  if should_preprocess then
    contents = preprocess(contents)
  end
  preview.show(contents, {
    title = history_type .. " entry " .. history.pos .. "/" .. #entries,
    filetype = entry.filetype,
  })
end

vim.api.nvim_create_augroup("UserYankHistory", {})
vim.api.nvim_create_autocmd("TextYankPost ", {
  group = "UserYankHistory",
  callback = handle_yank_post,
})

vim.api.nvim_create_autocmd("RecordingLeave", {
  group = "UserYankHistory",
  callback = handle_macro_post,
})

local function cycle_yank(direction)
  cycle(direction, histories.yank, "Yank", get_default_register(), M.add_entry_to_yank_history)
end

local function cycle_macro(direction)
  cycle(direction, histories.macro, "Macro", "a", M.add_entry_to_macro_history, { should_preprocess = false })
end

vim.keymap.set("n", "ä", function()
  cycle_yank(-1)
end)
vim.keymap.set("n", "Ä", function()
  cycle_yank(1)
end)

vim.keymap.set("n", "ü", function()
  cycle_macro(-1)
end)
vim.keymap.set("n", "Ü", function()
  cycle_macro(1)
end)

local function bind_paste(keys)
  local callback = function()
    add_default_register_to_history()
    vim.api.nvim_feedkeys(keys, "nx", false)
  end
  vim.keymap.set({ "n" }, keys, callback, { silent = true })
end

F.foreach({ "p", "P", "gP" }, bind_paste)

return M
