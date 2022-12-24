local unpack = unpack

local F = require("user.functional")
local U = require("user.utils")

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
local function write_tmux_clipboard(contents, regtype)
  local content = table.concat(contents, "\n")
  content = content .. (regtype == "V" and "\n" or "")
  if redirect_to_clipboard then
    execute({ "load-buffer", "-w", "-" }, { input = content })
  else
    execute({ "load-buffer", "-" }, { input = content })
  end
end

local function tmux_post_yank()
  write_tmux_clipboard(vim.v.event.regcontents, vim.v.event.regtype)
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

local function entry_length(entry)
  return F.sum(F.map(entry.contents, function(content)
    return #content
  end))
end

local History = require("user.history")
local history = History:new({
  name = "Yank",
  register = function()
    local clipboard_flags = vim.opt.clipboard:get()
    if F.contains(clipboard_flags, "unnamedplus") then
      return "+"
    elseif F.contains(clipboard_flags, "unnamed") then
      return "*"
    end
    return '"'
  end,
  preview_preprocess = function(lines)
    lines = U.replace_tabs(lines)
    lines = U.fix_indent(lines)
    return lines
  end,
  write_callback = function(register)
    write_tmux_clipboard(vim.fn.getreg(register, 1, true), vim.fn.getregtype(register))
  end,
  filter = function(entry)
    local length = entry_length(entry)
    if entry.regtype == "v" and length <= 3 then
      return true
    end
    if 1024 * 1024 < length then
      return true
    end
    return false
  end,
})

vim.api.nvim_create_augroup("UserYankHistory", {})
vim.api.nvim_create_autocmd("TextYankPost ", {
  group = "UserYankHistory",
  callback = function(args)
    history:add({
      regtype = vim.v.event.regtype,
      contents = vim.v.event.regcontents,
      filetype = vim.api.nvim_buf_get_option(args.buf, "filetype"),
    })
  end,
})

vim.keymap.set("n", "ä", function()
  history:cycle(-1)
end)
vim.keymap.set("n", "Ä", function()
  history:cycle(1)
end)

F.load("cmp", function(cmp)
  cmp.register_source("yank_history", history:make_completion_source():new())
end)

return { history = history }
