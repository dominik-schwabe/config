vim.loader.enable()

require("user.debug")

vim.cmd("colorscheme monokai")

require("user.options")
require("user.plugins")
require("user.custom")
require("user.mappings")
require("user.autocmds")

local F = require("user.functional")
local U = require("user.utils")

require("repl").setup({
  preferred = {
    python = { "ipython", "python", "python3", "qtconsole" },
    r = { "radian", "R" },
    lua = { "lua5.4", "luajit" },
  },
  listed = false,
  debug = false,
  ensure_win = true,
})

local send = require("repl.send")
local window = require("repl.window")
local repls = F.keys(require("repl.repls").repls)

local function mark_jump()
  vim.cmd("mark '")
end

vim.api.nvim_create_autocmd("FileType", {
  group = "user",
  callback = function(args)
    local bufopt = vim.bo[args.buf]
    if F.contains(repls, bufopt.filetype) then
      vim.keymap.set(
        "n",
        "<C-space>",
        F.chain(mark_jump, send.paragraph),
        { buffer = args.buf, desc = "send paragraph" }
      )
      vim.keymap.set("n", "<CR>", F.f(send.line_next), { buffer = args.buf, desc = "send line and go next" })
      vim.keymap.set("x", "<CR>", F.f(send.visual), { buffer = args.buf, desc = "send visual" })
      vim.keymap.set("n", "=", F.f(send.line), { buffer = args.buf, desc = "send line and stay" })
      vim.keymap.set("n", "<leader><space>", F.f(send.buffer), { buffer = args.buf, desc = "send buffer" })
      vim.keymap.set("n", "<leader>m", F.f(send.motion), { buffer = args.buf, desc = "send motion" })
      vim.keymap.set("n", "<leader>M", F.f(send.newline), { buffer = args.buf, desc = "send newline" })
      vim.keymap.set({ "n", "i", "t" }, "<F4>", F.f(window.toggle_repl), { buffer = args.buf, desc = "toggle repl" })
    end
  end,
})

F.load("colorizer", function(colorizer)
  colorizer.setup({
    filetypes = { "*", "!cmp_menu" },
    user_default_options = {
      rgb_fn = true,
      hsl_fn = true,
      tailwind = true,
      always_update = true,
    },
  })
end)
