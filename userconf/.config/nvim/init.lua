pcall(require, "impatient")

require("user.options")
require("user.plugins")
require("user.mappings")
require("user.custom")

vim.cmd("colorscheme monokai")

local F = require("user.functional")

vim.api.nvim_create_autocmd("CmdWinEnter", {
  command = "quit",
})
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "python",
--   command = "setlocal tabstop=4 shiftwidth=4 softtabstop=4",
-- })

vim.cmd("au BufEnter * set fo-=c fo-=r fo-=o", false)
-- vim.cmd("au BufEnter * set fo-=o", false)

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

pcall(require, "user.plugins.colorizer")

require("repl").setup({
  preferred = {
    python = { "ipython", "python", "python3", "qtconsole" },
    r = { "radian", "R" },
    lua = { "lua5.1", "luajit" },
  },
  listed = true,
  debug = false,
  ensure_win = true,
})

vim.keymap.set("n", "<F3>", "<CMD>UndotreeToggle<CR>")

local send = require("repl.send")
local window = require("repl.window")

vim.keymap.set("n", "<C-space>", F.f(send.paragraph))
vim.keymap.set("n", "<CR>", F.f(send.line_next))
vim.keymap.set("x", "<CR>", F.f(send.visual))
vim.keymap.set("n", "=", F.f(send.line))
vim.keymap.set("n", "<leader><space>", F.f(send.buffer))
vim.keymap.set("n", "m", F.f(send.motion))
vim.keymap.set("n", "M", F.f(send.newline))
vim.keymap.set({ "n", "i", "t" }, "<F4>", F.f(window.toggle_repl))

local new_regex = require("regex.new-regex")
R = function(regex)
  D(new_regex.E2v(regex))
end
S = function(str, regex)
  D(vim.fn.substitute(str, regex, "[-]", ""))
end
-- local legacy_regex = require("regex.legacy-regex")
-- local mod = "iISCDMm"
-- function ThisRegex()
--   local regex = [[[^\.\,\)\(\s]$]]
--   local n = legacy_regex.E2v(regex, mod)
--   local v = new_regex.E2v(regex, mod)

--   print(n == v, regex, "--------", n, "--------", v)
-- end

-- local tests = {
--   [[(?<=abc),\d+,(?=xzy)]],
--   [[\(\d\{1,3}\)\%(\(\d\d\d\)\+\($\|\D\)\)\@=]],
-- }

-- function TestRegexes()
--   print(mod)
--   local regexes = vim.fn.readfile(vim.fn.glob("~/.regexlist.txt"))
--   for _, value in ipairs(tests) do
--     regexes[#regexes + 1] = value
--   end
--   for i, regex in ipairs(regexes) do
--     if i % 1000 == 0 then
--       print(i)
--     end
--     if i > 100 then
--       break
--     end
--     local n = legacy_regex.E2v(regex)
--     local v = new_regex.E2v(regex)
--     if n ~= v then
--       print(i, regex, "--------", n, "--------", v)
--       return
--     end
--   end
--   print("success")
-- end

-- vim.keymap.set("n", "<space>n", ThisRegex)
-- vim.keymap.set("n", "<space>N", TestRegexes)
