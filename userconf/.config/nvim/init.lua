require("options")
require("mappings")
require("plugins")

local opt = vim.opt
local o = vim.o
local wo = vim.wo
local bo = vim.bo
local g = vim.g
local fn = vim.fn
local cmd = vim.cmd
local api = vim.api
local map = api.nvim_set_keymap
local ncmd = api.nvim_command
local exec =  api.nvim_exec

vim.lsp.set_log_level("debug")

local def_opt = {noremap = true, silent = true}
local expr_opt = {noremap = true, silent = true, expr = true}

map('', '<C-p>', ':Telescope find_files<cr>', def_opt)
map('i', '<C-p>', '<esc>:Telescope find_files<cr>', def_opt)

require'compe'.setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = false;

  source = {
    path = true;
    buffer = true;
    calc = true;
    vsnip = true;
    nvim_lsp = true;
    nvim_lua = true;
    spell = true;
    tags = true;
    snippets_nvim = true;
    treesitter = true;
  };
}

local t = function(str)
  return api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = fn.col('.') - 1
    if col == 0 or fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

_G.tab_complete = function()
  if fn.pumvisible() == 1 then
    return t '<C-n>'
  elseif fn.call('vsnip#available', {1}) == 1 then
    return t '<Plug>(vsnip-expand-or-jump)'
  elseif check_back_space() then
    return t '<Tab>'
  else
    return fn['compe#complete']()
  end
end
_G.s_tab_complete = function()
  if fn.pumvisible() == 1 then
    return t '<C-p>'
  elseif fn.call('vsnip#jumpable', {-1}) == 1 then
    return t '<Plug>(vsnip-jump-prev)'
  else
    return t '<S-Tab>'
  end
end

map('i', '<Tab>', 'v:lua.tab_complete()', {expr = true})
map('s', '<Tab>', 'v:lua.tab_complete()', {expr = true})
map('i', '<S-Tab>', 'v:lua.s_tab_complete()', {expr = true})
map('s', '<S-Tab>', 'v:lua.s_tab_complete()', {expr = true})
map('i', '<C-Space>', 'compe#complete()', expr_opt)
map('i', '<CR>', "compe#confirm('<CR>')", expr_opt)
map('i', '<C-e>', "compe#close('<C-e>')", expr_opt)
map('i', '<C-f>', "compe#scroll({ 'delta': +4 })", expr_opt)
map('i', '<C-d>', "compe#scroll({ 'delta': -4 })", expr_opt)


require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
  },
  indent = {
    enable = true,
  },
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = 1000,
  },
  ensure_installed = {
    "bash",
    "bibtex",
    "c",
    "cpp",
    "css",
    "dockerfile",
    "html",
    "javascript",
    "json",
    "latex",
    "lua",
    "python",
    "typescript",
    "vim",
    "yaml"
  }
}
require('kommentary.config').configure_language('default', {
    prefer_single_line_comments = true,
})
g.kommentary_create_default_mappings = false
map('n', 'gc', '<Plug>kommentary_line_default', {silent = true})
map('v', 'gc', '<Plug>kommentary_visual_default', {silent = true})

local nvim_lsp = require('lspconfig')

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) api.nvim_buf_set_keymap(bufnr, ...) end

  require'lsp_signature'.on_attach({bind = true})
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', def_opt)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', def_opt)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', def_opt)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', def_opt)
  buf_set_keymap('n', '<space>k', '<cmd>lua vim.lsp.buf.signature_help()<CR>', def_opt)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', def_opt)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', def_opt)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', def_opt)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', def_opt)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', def_opt)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', def_opt)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', def_opt)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', def_opt)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', def_opt)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', def_opt)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', def_opt)
  buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', def_opt)
end

require'lspinstall'.setup()
local servers = require'lspinstall'.installed_servers()
for _, server in pairs(servers) do
  nvim_lsp[server].setup{on_attach = on_attach}
end

-- vim-matchup
g.matchup_matchparen_enabled = 1

-- ListToggle
g.lt_height = 10
map("", "ä", ":LToggle<cr>", def_opt)
map("", "Ö", ":QToggle<cr>", def_opt)

-- vim-asterisk
map("", "*", "<Plug>(asterisk-*)", {})
map("", "#", "<Plug>(asterisk-#)", {})
map("", "g*", "<Plug>(asterisk-g*)", {})
map("", "g#", "<Plug>(asterisk-g#)", {})
map("", "z*", "<Plug>(asterisk-z*)", {})
map("", "gz*", "<Plug>(asterisk-gz*)", {})
map("", "z#", "<Plug>(asterisk-z#)", {})
map("", "gz#", "<Plug>(asterisk-gz#)", {})

-- ferret
_G.SearchFilesRegex = function()
  fn.inputsave()
  local search = fn.input("Search in files: ")
  fn.inputrestore()
  if not search ~= "" then
    print(search)
    exec('Ack -i ' .. fn.substitute(fn.escape(search, ' '), '^-', '\\[-\\]', ''), false)
  end
end
map("", "_", ":call v:lua.SearchFilesRegex()<cr>", def_opt)
map("", "<leader>a", "<Plug>(FerretAckWord)", def_opt)
g.FerretMap = 0
g.FerretMaxResults = 1000

-- rooter
g.rooter_change_directory_for_non_project_files = 'current'
g.rooter_patterns = { '.git', '_darcs', '.hg', '.bzr', '.svn', 'Makefile', '>site-packages', 'package.json', 'package-lock.json' }

-- bufexplorer
g.bufExplorerDefaultHelp=0
g.bufExplorerDetailedHelp=0
g.bufExplorerFindActive=1
g.bufExplorerShowDirectories=0
g.bufExplorerShowNoName=0
g.bufExplorerShowRelativePath=1
g.bufExplorerShowTabBuffer=1
g.bufExplorerShowUnlisted=0
g.bufExplorerSortBy='mru'
g.bufExplorerSplitBelow=1
g.bufExplorerSplitRight=1
g.bufExplorerDisableDefaultKeyMapping=1
map("", "<F2>", ":ToggleBufExplorer<cr>", def_opt)
map("i", "<F2>", "<esc>:ToggleBufExplorer<cr>", def_opt)

-- vimtex
g.vimtex_compiler_progname = 'nvr'
g.vimtex_matchparen_enabled = 0
g.tex_flavor = 'latex'
g.vimtex_view_method = 'zathura'
g.vimtex_quickfix_mode = 2
g.vimtex_view_skim_reading_bar = 1
g.vimtex_quickfix_autoclose_after_keystrokes = 2
g.vimtex_quickfix_open_on_warning = 0
-- g.vimtex_quickfix_ignore_filters = {'overfull', 'underfull'}
g.tex_conceal = 'abdmg'

cmd([[au FileType tex setlocal conceallevel=1]], false)
cmd([[au FileType tex :NoMatchParen]], false)

-- argwrap
map('', 'Y', ':ArgWrap<cr>', def_opt)

-- sideways
map("", "R", ":SidewaysLeft<cr>", def_opt)
map("", "U", ":SidewaysRight<CR>", def_opt)

-- tmux
g.tmux_navigator_disable_when_zoomed = 1

-- zoomwintab
g.zoomwintab_remap = 0

-- eregex.vim
g.eregex_default_enable = 0

-- spellcheck
g.LangIndex = 0
g.LangList = {'en_us', 'de_de'}
_G.NextSpellLang = function()
  g.LangIndex = (g.LangIndex + 1) % (#g.LangList + 1)
  if g.LangIndex == 0 then
    wo.spell = false
    print("nospell")
  else
    local lang = g.LangList[g.LangIndex]
    bo.spelllang = lang
    wo.spell = true
    print("language: " .. lang)
  end
end
map("", "<F7>", ":call v:lua.NextSpellLang()<cr>", def_opt)
map("i", "<F7>", ":call v:lua.NextSpellLang()<cr>", def_opt)



-- smart resize
local function resize_height (val) api.nvim_win_set_height(0, api.nvim_win_get_height(0) + val) end
local function resize_width (val) api.nvim_win_set_width(0, api.nvim_win_get_width(0) + val) end
_G.SmartResize = function(dir)
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
map("", "+", ":call v:lua.SmartResize(0)<cr>", def_opt)
map("", "-", ":call v:lua.SmartResize(1)<cr>", def_opt)

g.python3_host_prog = '/usr/bin/python3'

if os.getenv("ASDF_DIR") ~= "" and not fn.empty(fn.glob(os.getenv("ASDF_DIR") .. '/shims/python3')) then
  g.python3_host_prog = os.getenv("ASDF_DIR") .. '/shims/python3'
end

g.python_host_prog = '/usr/bin/python2'
if os.getenv("ASDF_DIR") ~= "" and not fn.empty(fn.glob(os.getenv("ASDF_DIR") .. '/shims/python2')) then
  g.python_host_prog = os.getenv("ASDF_DIR") .. '/shims/python2'
end

map("", "<F12>", ":ZoomWinTabToggle<cr>", def_opt)
map("i", "<F12>", "<esc>:ZoomWinTabToggle<cr>", def_opt)
map("t", "<F12>", "<C-\\><C-n>:ZoomWinTabToggle<cr>", def_opt)
map("", "<F12>", ":ZoomWinTabToggle<cr>", def_opt)
map("i", "<F12>", "<esc>:ZoomWinTabToggle<cr>", def_opt)
map("t", "<F12>", "<C-\\><C-n>:ZoomWinTabToggle<cr>", def_opt)

map("t", "<F2>", "<C-\\><C-n>:ToggleBufExplorer<cr>", def_opt)
require('bqf').setup({
  auto_resize_height = false,
})


g.tokyonight_transparent = true
g.tokyonight_terminal_colors = false
g.tokyonight_style = "storm"
cmd('syntax on')
cmd('colorscheme monokai')
cmd([[hi LineNr guibg=none]])
cmd([[hi Normal guibg=none]])
cmd([[hi SignColumn guibg=none]])
cmd([[hi clear Conceal]])

require("colorizer").setup()
