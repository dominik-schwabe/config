pcall(require, "impatient")
vim.cmd("colorscheme monokai")

require("myconfig.options")
require("myconfig.plugins")
require("myconfig.mappings").setup()
require("myconfig.custom")

vim.api.nvim_create_autocmd("CmdWinEnter", {
  command = "quit",
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  command = "setlocal tabstop=4 shiftwidth=4 softtabstop=4",
})
-- cmd("au BufEnter * set fo-=c fo-=r fo-=o", false)
function Test()
  local topline = vim.fn.line("w0")
  if
    vim.api.nvim_open_win(0, true, {
      relative = "editor",
      row = 0,
      col = 0,
      height = 1000,
      width = 1000,
      focusable = true,
      zindex = 5,
      border = "none",
    }) ~= 0
  then
    vim.fn.winrestview({ topline = topline })
    vim.wo.winhighlight = "SignColumn:TabLineSel"
  end
end

require("myconfig.plugins.colorizer")

vim.keymap.set("n", "<F11>", "<CMD>ReplSendParagraph<CR>")

require("repl").setup({
  preferred = { python = { "ipython", "python", "python3" }, r = { "radian", "R" } },
  listed = true,
  debug = false,
  ensure_win = true,
})
