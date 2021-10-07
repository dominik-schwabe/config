local o = vim.o
local opt = vim.opt
local g = vim.g
local fn = vim.fn
local api = vim.api
local cmd = vim.cmd
local map = api.nvim_set_keymap

local def_opt = {noremap = true, silent = true}

function SetSpell(lang)
  if lang == "" or (o.spelllang == lang and o.spell) then
    opt.spell = false
    print("nospell")
  else
    opt.spelllang = lang
    opt.spell = true
    print("language: " .. lang)
  end
end
map("", "<space>ss", "<CMD>lua SetSpell('')<CR>", def_opt)
map("", "<space>sd", "<CMD>lua SetSpell('de_de')<CR>", def_opt)
map("", "<space>se", "<CMD>lua SetSpell('en_us')<CR>", def_opt)

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

map("", "<F10>", "<CMD>lua ToggleTerm(10, true)<CR>", def_opt)
map("i", "<F10>", "<ESC>:lua ToggleTerm(10, true)<CR>", def_opt)
map("t", "<F10>", "<CMD>lua ToggleTerm(10, true)<CR>", def_opt)
map("", "<F22>", "<CMD>lua ToggleTerm(10, false)<CR>", def_opt)
map("i", "<F22>", "<ESC>:lua ToggleTerm(10, false)<CR>", def_opt)
map("t", "<F22>", "<CMD>lua ToggleTerm(10, false)<CR>", def_opt)

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
map("", "+", "<cmd>lua SmartResize(0)<cr>", def_opt)
map("", "-", "<cmd>lua SmartResize(1)<cr>", def_opt)

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
map("n", "gl", "<CMD>lua LatexSubstitude()<CR>", def_opt)

-- yank and substitude on selection
function SubstitudeSelection()
  api.nvim_feedkeys(":s/\\(" .. fn.escape(fn.getreg("+"), "\\") .. "\\)/\\1", "n", true)
end
map("x", "<space>s", "<CMD>lua SubstitudeSelection()<CR>", def_opt)

function LinePercent()
    return string.format("%d%%", fn.line('.') * 100 / fn.line('$'))
end

-- debugging
function d(obj)
  print(vim.inspect(obj))
end

function LspConfig()
  for _, client in pairs(vim.lsp.buf_get_clients()) do
    d(client.config.settings)
  end
end

map("n", "<space>ld", "<CMD>lua LspConfig()<CR>", def_opt)
