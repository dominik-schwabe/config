local F = require("user.functional")

local opts = {
  use_default_keymaps = false,
  check_syntax_error = true,
  cursor_behavior = "hold",
  notify = true,
  max_join_length = 100000,
}

F.load("mini.splitjoin", function(splitjoin)
  splitjoin.setup()
  opts.notify = false
  opts.on_error = function(msg, code, ...)
    if code == 3 then
      splitjoin.toggle()
    else
      vim.notify(string.format(msg, ...), code)
    end
  end
end)

local treesj = require("treesj")
treesj.setup(opts)

vim.keymap.set({ "n", "x" }, "Y", treesj.toggle, { desc = "toggle split join" })
