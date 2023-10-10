local tmux = require("user.custom.tmux")

local F = require("user.functional")
local U = require("user.utils")

local function entry_length(entry)
  return F.sum(F.map(entry.contents, function(content)
    return #content
  end))
end

local MIN_SIZE = 4
local MAX_SIZE = 1024 * 1024

local History = require("user.history")
local conf = {
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
  filter = function(entry)
    local length = entry_length(entry)
    if length < MIN_SIZE or length > MAX_SIZE then
      return true
    end
    return false
  end,
}
if tmux.loaded then
  function conf.regtype_normalization(regtype)
    if regtype ~= "V" and regtype ~= "v" then
      return "v"
    end
    return regtype
  end
  function conf.write_callback(register)
    tmux.write_clipboard(vim.fn.getreg(register, 1, true), vim.fn.getregtype(register))
  end
end
local history = History:new(conf)

vim.api.nvim_create_augroup("UserYankHistory", {})
vim.api.nvim_create_autocmd("TextYankPost", {
  group = "UserYankHistory",
  callback = function(args)
    history:add({
      regtype = vim.v.event.regtype,
      contents = vim.v.event.regcontents,
      filetype = vim.bo[args.buf].filetype,
    })
  end,
})

vim.keymap.set("n", "ä", function()
  history:cycle(1)
end, { desc = "select next yank from history" })
vim.keymap.set("n", "Ä", function()
  history:cycle(-1)
end, { desc = "select previous yank from history" })

local function bind_paste_func(key)
  vim.keymap.set("n", key, function()
    history:add_register()
    return key
  end, { desc = "paste selection (" .. key .. ")", expr = true })
end

bind_paste_func("p")
bind_paste_func("P")
-- bind_paste_func("gp")
-- bind_paste_func("gP")

F.load("cmp", function(cmp)
  cmp.register_source("yank_history", history:make_completion_source():new())
end)

return { history = history }
