local o = vim.o
local b = vim.b
local opt = vim.opt
local bo = vim.bo
local fn = vim.fn
local api = vim.api
local cmd = vim.cmd
local buf_map = vim.api.nvim_buf_set_keymap

local get_visual_selection = require("myconfig.utils").get_visual_selection

local config = require("myconfig.config")

local def_opt = { noremap = true, silent = true }

function SetSpell(lang)
  if lang == nil or (o.spelllang == lang and o.spell) then
    opt.spell = false
    print("nospell")
  else
    opt.spelllang = lang
    opt.spell = true
    print("language: " .. lang)
  end
end

cmd("command! -nargs=* SetSpell call luaeval('SetSpell(_A[1])', [<f-args>])")

-- toggle terminal
local term_buf = 0
local term_win = 0
function OpenTerm(height, bottom)
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

function ToggleTerm(height, bottom)
  if fn.win_gotoid(term_win) ~= 0 then
    local this_window = fn.winnr()
    local is_bottom = (this_window == fn.winnr("h"))
      and (this_window == fn.winnr("l"))
      and (this_window == fn.winnr("j"))
    cmd("hide")
    if is_bottom ~= bottom then
      OpenTerm(height, bottom)
    end
  else
    OpenTerm(height, bottom)
  end
end

cmd("command! ToggleTermBottom lua ToggleTerm(10, true)")
cmd("command! ToggleTermRight lua ToggleTerm(10, false)")

-- smart resize
local function resize_height(val)
  api.nvim_win_set_height(0, api.nvim_win_get_height(0) + val)
end
local function resize_width(val)
  api.nvim_win_set_width(0, api.nvim_win_get_width(0) + val)
end
function SmartResize(dir)
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

cmd("command! SmartResizeExpand lua SmartResize(0)")
cmd("command! SmartResizeReduce lua SmartResize(1)")

-- latex for grammar checking
function LatexSubstitude()
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

cmd("command! LatexSubstitude lua LatexSubstitude()")

-- yank and substitude on selection
function SubstitudeSelection()
  api.nvim_feedkeys(":s/\\(" .. fn.escape(fn.getreg("+"), "\\") .. "\\)/\\1", "n", true)
end

cmd("command! SubstitudeSelection lua SubstitudeSelection()")

-- line percent
function LinePercent()
  return string.format("%d%%", fn.line(".") * 100 / fn.line("$"))
end

-- debugging
function d(obj)
  print(vim.inspect(obj))
end

-- show settings of lspserver
function LspSettings()
  for _, client in pairs(vim.lsp.buf_get_clients()) do
    d(client.config.settings)
  end
end

cmd("command! LspSettings lua LspSettings()")

-- show lsp root
function LspRoot()
  for _, client in pairs(vim.lsp.buf_get_clients()) do
    d(client.config.root_dir)
  end
end

cmd("command! LspRoot lua LspRoot()")

-- term mode fix
function TermGoDirection(dir)
  b.term_was_normal_mode = fn.winnr() == fn.winnr(dir)
  cmd("wincmd " .. dir)
end

function EnterTerm()
  if not b.term_was_normal_mode then
    cmd("startinsert")
  end
end

cmd("command! -nargs=* TermGoDirection call luaeval('TermGoDirection(_A[1])', [<f-args>])")

-- quickfix quit
function QuickfixMapping()
  buf_map(0, "n", "q", "<cmd>q<cr>", def_opt)
end
cmd([[au filetype qf lua QuickfixMapping()]])

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

local function IsQuickfix(win)
  return win.quickfix == 1 and win.loclist == 0
end
local function IsLoclist(win)
  return win.quickfix == 1 and win.loclist == 1
end

local QuickfixExists = window_exists(IsQuickfix)
local LoclistExists = window_exists(IsLoclist)

function LoclistToggle()
  if LoclistExists() then
    cmd("lclose")
  else
    if not pcall(cmd, "lopen") then
      print("Loclist ist empty")
    end
  end
end

function QuickfixToggle()
  if QuickfixExists() then
    cmd("cclose")
  else
    cmd("botright copen")
  end
end

cmd("command! LoclistToggle lua LoclistToggle()")
cmd("command! QuickfixToggle lua QuickfixToggle()")

-- chmod
function ChmodCurrent(x)
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

cmd("command! ChmodSet lua ChmodCurrent(true)")
cmd("command! ChmodRemove lua ChmodCurrent(false)")

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

function TrailingHighlight(mode)
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

function UpdateTrailingHighlight()
  local filetype = fn.expand("<amatch>")
  if filetype == "" then
    filetype = api.nvim_buf_get_option(0, "filetype")
  end
  b.disable_trailing = contains(whitespace_blacklist, filetype) or not api.nvim_buf_get_option(0, "modifiable")
  TrailingHighlight("auto")
end

cmd([[augroup TrailingWhitespace
  au!
  au InsertLeave * lua TrailingHighlight("n")
  au InsertEnter * lua TrailingHighlight("i")
  au BufEnter * lua TrailingHighlight("auto")
  au FileType * lua UpdateTrailingHighlight()
  au OptionSet modifiable lua UpdateTrailingHighlight()
augroup END]])

function TrimWhitespace(buffer)
  buffer = api.nvim_buf_get_number(buffer)
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

cmd("command! TrimWhitespace lua TrimWhitespace(0)")

function ReloadConfig()
  for name, _ in pairs(package.loaded) do
    if name:match("^myconfig") then
      package.loaded[name] = nil
    end
  end

  dofile(vim.env.MYVIMRC)
end

local curr_rg_job = nil
local Job = require("plenary.job")
function Rg(string, raw, maximum)
  if string == "" then
    return
  end
  if curr_rg_job ~= nil then
    curr_rg_job:shutdown()
  end
  local args = { string, "-i", "-H", "--no-heading", "--vimgrep" }
  if raw then
    args[#args + 1] = "--fixed-strings"
  end
  -- local filepath = fn.expand("%:p:h")
  curr_rg_job = Job:new({
    command = "rg",
    args = args,
    interactive = false,
    cwd = fn.getcwd(),
    -- maximum_results = maximum,
    on_exit = function(j, return_val)
      if return_val ~= 0 then
        vim.schedule_wrap(function()
          vim.notify(table.concat(j:stderr_result(), "\n"), "ERR")
        end)()
      else
        vim.schedule_wrap(function()
          vim.fn.setqflist({}, "r", { title = "Search Results", lines = j:result() })
          api.nvim_command("cwindow")
        end)()
      end
    end,
  })
  curr_rg_job:after(function()
    curr_rg_job = nil
  end)
  curr_rg_job:start()
end

function RgWord()
  Rg(vim.fn.expand("<cword>"), true)
end

function RgInput()
  fn.inputsave()
  local query = fn.input("Search in files: ")
  fn.inputrestore()
  if not (query == "") then
    return Rg(query, false)
  end
end

function RgVisual()
  local selection = get_visual_selection(0)
  if #selection == 0 then
    print("empty selection")
    return
  end
  Rg(table.concat(get_visual_selection(0), ""), true)
end

cmd("command! RgWord lua RgWord()")
cmd("command! RgInput lua RgInput()")
cmd("command! RgVisual lua RgVisual()")
