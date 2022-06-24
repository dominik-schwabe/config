local better_n = require("better-n")

better_n.setup({
  callbacks = {
  --   mapping_executed = function(_mode, _key)
  --     vim.cmd([[ nohl ]])
  --   end,
  },
  mappings = {
    ["#"] = { previous = "n", next = "<s-n>" },
    ["F"] = { previous = ";", next = "," },
    ["T"] = { previous = ";", next = "," },
    ["w"] = { previous = "n", next = "<s-n>" },

    ["?"] = { previous = "n", next = "<s-n>", cmdline = true },
  },
})

vim.keymap.set("n", "n", better_n.n, { nowait = true })
vim.keymap.set("n", "<s-n>", better_n.shift_n, { nowait = true })
