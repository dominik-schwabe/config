local def_opt = {noremap = true, silent = true}

local fn = vim.fn
local api = vim.api
local b = vim.b
local map = api.nvim_set_keymap
local exec =  api.nvim_exec
local cmd = vim.cmd
local buf_map = api.nvim_buf_set_keymap
local noremap = {noremap = true}

map('x', 'p', '"_dP', def_opt)
map('x', '<space>P', 'p', def_opt)
map('', 'Q', ':qa<CR>', def_opt)
map('', '<left>', '<CMD>wincmd H<CR>', def_opt)
map('t', '<left>', '<CMD>wincmd H<CR>', def_opt)
map('', '<right>', '<CMD>wincmd L<CR>', def_opt)
map('t', '<right>', '<CMD>wincmd L<CR>', def_opt)
map('', '<up>', '<CMD>wincmd K<CR>', def_opt)
map('t', '<up>', '<CMD>wincmd K<CR>', def_opt)
map('', '<down>', '<CMD>wincmd J<CR>', def_opt)
map('t', '<down>', '<CMD>wincmd J<CR>', def_opt)

map('n', 'ö', ':noh<CR>', def_opt)
map("", "<space>k", "lua d(vim.fn.mode())", def_opt)

cmd("au CmdWinEnter * quit")

map('v', '<', '<gv', def_opt)
map('v', '>', '>gv', def_opt)

-- map('', '<C-h>', '<CMD>wincmd h<CR>', def_opt)
-- map('', '<C-j>', '<CMD>wincmd j<CR>', def_opt)
-- map('', '<C-k>', '<CMD>wincmd k<CR>', def_opt)
-- map('', '<C-l>', '<CMD>wincmd l<CR>', def_opt)

map('t', '<C-h>', '<C-\\><C-n><C-W>h', def_opt)
map('t', '<C-j>', '<C-\\><C-n><C-W>j', def_opt)
map('t', '<C-k>', '<C-\\><C-n><C-W>k', def_opt)
map('t', '<C-l>', '<C-\\><C-n><C-W>l', def_opt)

map("n", "db", "dvb", def_opt)
map("n", "<C-g>", "2<C-g>", noremap)

exec([[au FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4]], false)
exec([[au BufEnter * set fo-=c fo-=r fo-=o]], false)
exec([[au TermOpen * setlocal nonumber norelativenumber signcolumn=no filetype=term]], false)

function TermGoDirection(dir)
  b.term_was_normal_mode = fn.winnr() == fn.winnr(dir)
  cmd("wincmd " .. dir)
end

function EnterTerm()
  if not b.term_was_normal_mode then
    cmd("startinsert")
  end
end

map("t", "<C-h>", [[<C-\><C-n>:lua TermGoDirection('h')<CR>]], def_opt)
map("t", "<C-j>", [[<C-\><C-n>:lua TermGoDirection('j')<CR>]], def_opt)
map("t", "<C-k>", [[<C-\><C-n>:lua TermGoDirection('k')<CR>]], def_opt)
map("t", "<C-l>", [[<C-\><C-n>:lua TermGoDirection('l')<CR>]], def_opt)
cmd([[au BufEnter term://* lua EnterTerm()]])
cmd([[au TermClose term://* lua vim.api.nvim_buf_delete("<abuf>", {force = true})]])

function QuickfixMapping()
  buf_map(0, "n", "q", "<cmd>q<cr>", def_opt)
end
cmd([[au filetype qf lua QuickfixMapping()]])

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

map("", "<leader>x", "<CMD>lua ChmodCurrent(true)<CR>", def_opt)
map("", "<leader>X", "<CMD>lua ChmodCurrent(false)<CR>", def_opt)

map("", "Ä", "<CMD>lua LoclistToggle()<CR>", def_opt)
map("", "Ö", "<CMD>lua QuickfixToggle()<CR>", def_opt)
