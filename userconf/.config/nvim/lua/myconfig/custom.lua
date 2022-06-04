local o = vim.o
local b = vim.b
local opt = vim.opt
local fn = vim.fn
local api = vim.api
local cmd = vim.cmd

local get_visual_selection = require("myconfig.utils").get_visual_selection

local config = require("myconfig.config")

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

vim.api.nvim_create_user_command("SetSpell", function(arg)
  set_spell(arg.fargs[1])
end, { nargs = "*" })

-- toggle terminal
local term_buf = 0
local term_win = 0
local function open_term(height, bottom)
  if bottom then
    cmd("botright new")
    api.nvim_win_set_height(0, height)
  else
    cmd("vertical botright new")
  end
  if term_buf ~= 0 and api.nvim_buf_is_loaded(term_buf) then
    api.nvim_win_set_buf(0, term_buf)
  else
    fn.termopen(os.getenv("SHELL"), { detach = 0 })
    term_buf = fn.bufnr("")
    api.nvim_buf_set_name(term_buf, "term://toggleterm")
    api.nvim_buf_set_option(term_buf, "buflisted", false)
  end
  cmd("startinsert")
  term_win = fn.win_getid()
end

local function toggle_term(height, bottom)
  if fn.win_gotoid(term_win) ~= 0 then
    local this_window = fn.winnr()
    local is_bottom = (this_window == fn.winnr("h"))
      and (this_window == fn.winnr("l"))
      and (this_window == fn.winnr("j"))
    cmd("hide")
    if is_bottom ~= bottom then
      open_term(height, bottom)
    end
  else
    open_term(height, bottom)
  end
end

vim.api.nvim_create_user_command("ToggleTermBottom", function()
  toggle_term(10, true)
end, {})
vim.api.nvim_create_user_command("ToggleTermRight", function()
  toggle_term(10, false)
end, {})

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

vim.api.nvim_create_user_command("SmartResizeExpand", function()
  smart_resize(0)
end, {})

vim.api.nvim_create_user_command("SmartResizeReduce", function()
  smart_resize(1)
end, {})

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

vim.api.nvim_create_user_command("LatexSubstitude", function()
  latex_substitude()
end, {})

-- yank and substitude on selection
local function substitude_selection()
  api.nvim_feedkeys(":s/\\(" .. fn.escape(fn.getreg("+"), "\\") .. "\\)/\\1", "n", true)
end

vim.api.nvim_create_user_command("SubstitudeSelection", function()
  substitude_selection()
end, {})

-- line percent
function LinePercent()
  return string.format("%d%%", fn.line(".") * 100 / fn.line("$"))
end

-- debugging
function D(obj)
  print(vim.inspect(obj))
end

-- show settings of lspserver
local function lsp_settings()
  for _, client in pairs(vim.lsp.buf_get_clients()) do
    D(client.config.settings)
  end
end

vim.api.nvim_create_user_command("LspSettings", function()
  lsp_settings()
end, {})

-- show lsp root
local function lsp_root()
  for _, client in pairs(vim.lsp.buf_get_clients()) do
    D(client.config.root_dir)
  end
end

vim.api.nvim_create_user_command("LspRoot", function()
  lsp_root()
end, {})

-- term mode fix
local function term_go_direction(dir)
  b.term_was_normal_mode = fn.winnr() == fn.winnr(dir)
  cmd("wincmd " .. dir)
end

vim.api.nvim_create_user_command("TermGoDirection", function(arg)
  term_go_direction(arg.fargs[1])
end, { nargs = 1 })

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
    for _, win in ipairs(fn.getwininfo()) do
      if cb(win) then
        return true
      end
    end
    return false
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

vim.api.nvim_create_user_command("LoclistToggle", loclist_toggle, {})
vim.api.nvim_create_user_command("QuickfixToggle", quickfix_toggle, {})

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

vim.api.nvim_create_user_command("ChmodSet", function()
  chmod_current(true)
end, {})
vim.api.nvim_create_user_command("ChmodRemove", function()
  chmod_current(false)
end, {})

-- trailing whitespace
local function contains(list, x)
  for _, v in pairs(list) do
    if v == x then
      return true
    end
  end
  return false
end

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
    filetype = api.nvim_buf_get_option(0, "filetype")
  end
  b.disable_trailing = contains(whitespace_blacklist, filetype) or not api.nvim_buf_get_option(0, "modifiable")
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

local function reload_config()
  for name, _ in pairs(package.loaded) do
    if name:match("^myconfig") then
      package.loaded[name] = nil
    end
  end

  dofile(vim.env.MYVIMRC)
end

vim.api.nvim_create_user_command("ReloadConfig", reload_config, {})

local curr_rg_job = nil
local Job = require("plenary.job")
local function rg(string, raw, boundry, maximum)
  print(string)
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
    -- maximum_results = maximum,
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
  local selection = get_visual_selection(0)
  if #selection == 0 then
    print("empty selection")
    return
  end
  rg(table.concat(get_visual_selection(0), ""), true)
end

vim.api.nvim_create_user_command("RgWord", rg_word, {})
vim.api.nvim_create_user_command("RgInput", rg_input, {})
vim.api.nvim_create_user_command("RgVisual", rg_visual, {})

local function delete_term(args)
  api.nvim_buf_delete(args.buf, { force = true })
end

local function enter_term()
  if vim.o.buftype == "terminal" and not b.term_was_normal_mode then
    cmd("startinsert")
  end
end

vim.api.nvim_create_autocmd("TermOpen", {
  command = "setlocal nospell nonumber norelativenumber signcolumn=no filetype=term",
})
vim.api.nvim_create_autocmd("BufEnter", {
  callback = enter_term,
})
vim.api.nvim_create_autocmd("TermClose", {
  pattern = { "term://toggleterm", "term://ironrepl" },
  callback = delete_term,
})
