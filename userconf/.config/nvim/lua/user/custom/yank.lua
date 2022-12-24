local unpack = unpack

local tmux = require("user.custom.tmux")

local F = require("user.functional")
local U = require("user.utils")

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
    tmux.write_clipboard(vim.fn.getreg(register, 1, true), vim.fn.getregtype(register))
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
