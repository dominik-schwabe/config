local o = vim.o
local b = vim.b
local opt = vim.opt
local fn = vim.fn
local api = vim.api
local cmd = vim.cmd
local buf_map = vim.api.nvim_buf_set_keymap

local def_opt = {noremap = true, silent = true}

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
    fn.termopen(os.getenv("SHELL"), {detach = 0})
    cmd("file term://toggleterm")
    term_buf = fn.bufnr("")
    api.nvim_buf_set_option(term_buf, "buflisted", false)
  end
  cmd("startinsert")
  term_win = fn.win_getid()
end

function ToggleTerm(height, bottom)
  if fn.win_gotoid(term_win) ~= 0 then
    local this_window = fn.winnr()
    local is_bottom = (this_window == fn.winnr("h")) and (this_window == fn.winnr("l")) and (this_window == fn.winnr("j"))
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
local function resize_height (val) api.nvim_win_set_height(0, api.nvim_win_get_height(0) + val) end
local function resize_width (val) api.nvim_win_set_width(0, api.nvim_win_get_width(0) + val) end
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
    return string.format("%d%%", fn.line('.') * 100 / fn.line('$'))
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

local function IsQuickfix(win) return win.quickfix == 1 and win.loclist == 0 end
local function IsLoclist(win) return win.quickfix == 1 and win.loclist == 1 end

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
  if QuickfixExists() then cmd("cclose") else cmd("copen") end
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
