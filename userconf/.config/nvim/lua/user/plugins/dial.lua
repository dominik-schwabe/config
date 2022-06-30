local augend = require("dial.augend")

require("dial.config").augends:register_group({
  default = {
    augend.constant.new({
      elements = { "yes", "no" },
      word = true,
      cyclic = true,
    }),
    augend.constant.new({
      elements = { "true", "false" },
      word = true,
      cyclic = true,
    }),
    augend.constant.new({
      elements = { "True", "False" },
      word = true,
      cyclic = true,
    }),
    augend.constant.new({
      elements = { "TRUE", "FALSE" },
      word = true,
      cyclic = true,
    }),
    augend.constant.new({
      elements = { "[ ]", "[x]" },
      word = false,
      cyclic = true,
    }),
    augend.integer.new{
      radix = 10,
      natural = false,
    },
    augend.integer.alias.hex,
    augend.integer.alias.binary,
    augend.date.alias["%Y/%m/%d"],
    augend.date.alias["%H:%M:%S"],
  },
})

vim.keymap.set({ "n", "v" }, "<C-a>", "<Plug>(dial-increment)")
vim.keymap.set({ "n", "v" }, "<C-x>", "<Plug>(dial-decrement)")
vim.keymap.set("v", "g<C-a>", "<Plug>(dial-increment-additional)")
vim.keymap.set("v", "g<C-x>", "<Plug>(dial-decrement-additional)")
