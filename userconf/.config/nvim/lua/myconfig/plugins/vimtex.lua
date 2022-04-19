local g = vim.g

g.vimtex_compiler_progname = "nvr"
g.vimtex_complete_enabled = 0
g.vimtex_matchparen_enabled = 0
g.tex_flavor = "latex"
g.vimtex_view_method = "zathura"
g.vimtex_quickfix_mode = 2
g.vimtex_view_skim_reading_bar = 1
g.vimtex_quickfix_autoclose_after_keystrokes = 2
g.vimtex_quickfix_open_on_warning = 0
-- g.vimtex_quickfix_ignore_filters = {'overfull', 'underfull'}
g.tex_conceal = "abdmg"
g.texflavor = "latex"

vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  command = "setlocal conceallevel=1",
})
