local F = require("user.functional")

local treesj = require("treesj")
treesj.setup({
  {
    use_default_keymaps = false,
    check_syntax_error = true,
    cursor_behavior = "hold",
    notify = true,
    max_join_length = 100000,
  },
})

local splitjoin = F.load("mini.splitjoin", function(splitjoin)
  splitjoin.setup()
end)

local langs = require("treesj.langs").presets

local function toggle()
  if not splitjoin or langs[vim.bo.filetype] then
    treesj.toggle()
  else
    splitjoin.toggle()
  end
end

vim.keymap.set({ "n", "x" }, "Y", toggle, { desc = "toggle split join" })
