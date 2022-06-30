local o = vim.o
local b = vim.b
local bo = vim.bo
local opt = vim.opt
local fn = vim.fn
local api = vim.api
local cmd = vim.cmd

local utils = require("user.utils")
local F = require("user.functional")

local config = require("user.config")

local function set_spell(lang)
  if lang == nil or (o.spelllang == lang and o.spell) then
    opt.spell = false
    print("nospell")
  else
    opt.spelllang = lang
    opt.spell = true
    print("language: " .. lang)
  end
end

local function build_spell_func(lang)
  return F.f(set_spell, lang)
end

vim.api.nvim_create_user_command("SetSpell", function(arg)
  set_spell(arg.fargs[1])
end, { nargs = "*" })

vim.keymap.set({ "n", "x" }, "<space>ss", build_spell_func(nil))
vim.keymap.set({ "n", "x" }, "<space>sd", build_spell_func("de_de"))
vim.keymap.set({ "n", "x" }, "<space>se", build_spell_func("en_use"))

-- smart resize
local function resize_height(val)
  api.nvim_win_set_height(0, api.nvim_win_get_height(0) + val)
end
local function resize_width(val)
  api.nvim_win_set_width(0, api.nvim_win_get_width(0) + val)
end

local function smart_resize(dir)
  local hwin = fn.winnr("h")
  local kwin = fn.winnr("k")
  local lwin = fn.winnr("l")
  local jwin = fn.winnr("j")

  if hwin ~= lwin then
    if dir == 0 then
      resize_width(5)
    else
      resize_width(-5)
    end
  elseif kwin ~= jwin then
    if dir == 0 then
      resize_height(1)
    else
      resize_height(-1)
    end
  end
end

vim.keymap.set({ "n", "x" }, "+", F.f(smart_resize, 0))
vim.keymap.set({ "n", "x" }, "-", F.f(smart_resize, 1))

-- latex for grammar checking
local function latex_substitude()
  cmd([[%s/\v\$.{-}\$/Udo/ge]])
  cmd([[%s/\v\\ref\{.{-}\}/eins/ge]])
  cmd([[%s/\v\\cite\{.{-}\}//ge]])
  cmd([[%s/\v\\.{-}\{.{-}\}/Udo/ge]])
  cmd([[%s/\v[ ]+.{-}\{.{-}\}/Udo/ge]])
  cmd([[%s/\v ?\\//ge]])
  cmd([[%s/\v +\././ge]])
  cmd([[%s/\v +\,/,/ge]])
  cmd([[%s/\v[^a-zA-Z0-9üäöß.?!(),]/ /ge]])
  cmd([[%s/\v +/ /ge]])
end

vim.keymap.set("x", "<space>sl", latex_substitude)
vim.keymap.set("n", "gl", latex_substitude)

-- yank and substitude on selection
local function substitude_selection()
  api.nvim_feedkeys(":s/\\V\\(" .. fn.escape(fn.getreg("+"), "/\\") .. "\\)/\\1", "n", true)
end

vim.api.nvim_create_user_command("SubstitudeSelection", substitude_selection, {})

-- line percent
function LinePercent()
  return string.format("%d%%", fn.line(".") * 100 / fn.line("$"))
end

-- debugging
function D(...)
  local tbl = F.map({ ... }, vim.inspect)
  print(#tbl ~= 0 and unpack(tbl) or "--- empty ---")
end

function DK(list)
  D(F.keys(list))
end

-- term mode fix
local function leave_term()
  b.term_was_normal = true
  api.nvim_feedkeys(api.nvim_replace_termcodes("<C-\\><C-n>", true, true, true), "t", true)
end

vim.keymap.set("t", "<C-e>", leave_term)

-- quickfix quit
local function quickfix_mapping()
  vim.keymap.set("n", "q", "<cmd>q<cr>", { buffer = true })
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = quickfix_mapping,
})

-- quickfix/loclist toggle
local function window_exists(cb)
  return function()
    return F.any(fn.getwininfo(), cb)
  end
end

local function is_quickfix(win)
  return win.quickfix == 1 and win.loclist == 0
end
local function is_loclist(win)
  return win.quickfix == 1 and win.loclist == 1
end

local quickfix_exists = window_exists(is_quickfix)
local loclist_exists = window_exists(is_loclist)

local function loclist_toggle()
  if loclist_exists() then
    cmd("lclose")
  else
    if not pcall(cmd, "lopen") then
      print("Loclist ist empty")
    end
  end
end

local function quickfix_toggle()
  if quickfix_exists() then
    cmd("cclose")
  else
    cmd("botright copen")
  end
end

vim.keymap.set({ "n", "x" }, "Ä", loclist_toggle)
vim.keymap.set({ "n", "x" }, "Ö", quickfix_toggle)

-- chmod
local function chmod_current(x)
  local path = fn.expand("%:p")
  if fn.empty(fn.glob(path)) == 1 then
    print("this file does not exist")
    return
  end
  os.execute("chmod a" .. (x and "+" or "-") .. "x " .. path)
  if x then
    print("made executable")
  else
    print("removed execution rights")
  end
end

vim.keymap.set({ "n", "x" }, "<leader>x", F.f(chmod_current, true))
vim.keymap.set({ "n", "x" }, "<leader>X", F.f(chmod_current, false))

-- trailing whitespace
local whitespace_blacklist = config.whitespace_blacklist
local window_matches = {}

local trailing_patterns = {
  n = [[\(\s\|\r\)\+$]],
  i = [[\(\s\|\r\)\+\%#\@<!$]],
}

local function trailing_highlight(mode)
  if b.disable_trailing then
    mode = nil
  elseif mode == "auto" then
    mode = fn.mode()
  end
  local win_id = api.nvim_get_current_win()
  local win_state = window_matches[win_id]
  if win_state == nil and mode == nil then
    return
  end
  if win_state ~= nil then
    if win_state.mode == mode then
      return
    else
      pcall(fn.matchdelete, win_state.id)
      window_matches[win_id] = nil
    end
  end
  if mode ~= nil then
    local pattern = trailing_patterns[mode]
    local match_id = fn.matchadd("TrailingWhitespace", pattern)
    window_matches[win_id] = { id = match_id, mode = mode }
  end
end

local function update_trailing_highlight(args)
  local filetype = args.match
  if filetype == "" then
    filetype = bo.filetype
  end
  b.disable_trailing = F.contains(whitespace_blacklist, filetype) or not bo.modifiable
  trailing_highlight("auto")
end

vim.api.nvim_create_augroup("TrailingWhitespace", {})
vim.api.nvim_create_autocmd("InsertLeave", {
  group = "TrailingWhitespace",
  callback = function()
    trailing_highlight("n")
  end,
})
vim.api.nvim_create_autocmd("InsertEnter", {
  group = "TrailingWhitespace",
  callback = function()
    trailing_highlight("i")
  end,
})
vim.api.nvim_create_autocmd("BufEnter", {
  group = "TrailingWhitespace",
  callback = function()
    trailing_highlight("auto")
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  group = "TrailingWhitespace",
  callback = update_trailing_highlight,
})
vim.api.nvim_create_autocmd("OptionSet", {
  group = "TrailingWhitespace",
  pattern = "modifiable",
  callback = update_trailing_highlight,
})

local function trim_whitespace()
  local buffer = api.nvim_buf_get_number(0)
  if not api.nvim_buf_get_option(buffer, "modifiable") then
    print("not modifiable")
    return
  end
  local lines = api.nvim_buf_get_lines(buffer, 0, -1, false)
  for i = 1, #lines do
    lines[i] = lines[i]:gsub("%s+$", "")
  end
  local end_index = #lines
  while end_index > 0 and lines[end_index] == "" do
    lines[end_index] = nil
    end_index = end_index - 1
  end
  api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
end

vim.api.nvim_create_user_command("TrimWhitespace", trim_whitespace, {})
vim.keymap.set({ "n", "x" }, "<space>.", trim_whitespace)

local function reload_config()
  F.forkey(package.loaded, function(name)
    if name:match("^user") then
      package.loaded[name] = nil
    end
  end)
  dofile(vim.env.MYVIMRC)
  vim.notify("config reloaded", "info")
end

vim.api.nvim_create_user_command("ReloadConfig", reload_config, {})
vim.keymap.set({ "n", "x" }, "<space>v", reload_config)

local curr_rg_job = nil
local Job = require("plenary.job")
local function rg(string, raw, boundry, maximum)
  if string == "" then
    return
  end
  if curr_rg_job ~= nil then
    curr_rg_job:shutdown()
  end
  -- "--line-number",
  -- "--column",
  local args = {
    "--color=never",
    "--ignore-case",
    "--with-filename",
    "--no-heading",
    "--vimgrep",
    "--max-filesize=1M",
    "--ignore-file",
    ".gitignore",
  }
  if raw then
    string = vim.fn.escape(string, "^$.*+?()[]{}|")
  end
  if boundry then
    string = "\\b" .. string .. "\\b"
  end
  args[#args + 1] = string
  -- local filepath = fn.expand("%:p:h")
  curr_rg_job = Job:new({
    command = "rg",
    args = args,
    interactive = false,
    cwd = fn.getcwd(),
    maximum_results = maximum,
    on_exit = function(j, return_val)
      if return_val == 0 then
        vim.schedule_wrap(function()
          args[#args] = '"' .. vim.fn.escape(args[#args], '"') .. '"'
          local command = "rg " .. table.concat(args, " ")
          local lines = j:result()
          if #lines == 0 then
            vim.notify("nothing found", "ERR")
          else
            vim.fn.setqflist({}, "r", { title = command, lines = lines })
            api.nvim_command("botright copen")
          end
        end)()
      else
        vim.schedule_wrap(function()
          local lines = j:stderr_result()
          if #lines == 0 then
            vim.notify("nothing was returned", "ERR")
          else
            vim.notify(table.concat(lines, "\n"), "ERR")
          end
        end)()
      end
    end,
  })
  curr_rg_job:after(function()
    curr_rg_job = nil
  end)
  curr_rg_job:start()
end

local function rg_word()
  rg(vim.fn.expand("<cword>"), true, true)
end

local function rg_input()
  fn.inputsave()
  local query = fn.input("Search in files: ")
  fn.inputrestore()
  if not (query == "") then
    return rg(query, false)
  end
end

local function rg_visual()
  local selection = utils.get_visual_selection(0)
  if #selection == 0 then
    print("empty selection")
    return
  end
  rg(table.concat(selection, ""), true)
end

vim.api.nvim_create_user_command("RgWord", rg_word, {})
vim.api.nvim_create_user_command("RgInput", rg_input, {})
vim.api.nvim_create_user_command("RgVisual", rg_visual, {})

vim.keymap.set("n", "<c-_>", rg_word)
vim.keymap.set("x", "<c-_>", rg_visual)
vim.keymap.set({ "n", "x" }, "<space>x", F.f(rg, "local", true, true, 10))
vim.keymap.set("n", "_", rg_input)

local function delete_term(args)
  api.nvim_buf_delete(args.buf, { force = true })
end

local function enter_term()
  if vim.o.buftype == "terminal" and not b.term_was_normal then
    cmd("startinsert")
  end
end

vim.api.nvim_create_autocmd("TermOpen", {
  command = "setlocal nospell nonumber norelativenumber signcolumn=no filetype=term",
})
vim.api.nvim_create_autocmd("TermEnter", {
  callback = function()
    b.term_was_normal = false
  end,
})
vim.api.nvim_create_autocmd("BufEnter", {
  callback = enter_term,
})
vim.api.nvim_create_autocmd("TermClose", {
  pattern = { "term://repl*" },
  callback = delete_term,
})
