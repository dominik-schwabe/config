local F = require("user.functional")
local config = require("user.config")

local map_opts = { silent = true, nowait = true, mode = "v" }

local hydra_hint = [[
_H_ _J_ _K_ _L_
_f_:     VBox
_<F5>_:  VBoxD
_<F6>_:  VBoxH
_<F7>_:  VBoxO
_<F8>_:  VBoxDO
_<F9>_:  VBoxHO
_<F10>_: VFill
_<C-c>_: exit
]]

F.load("hydra", function(Hydra)
  Hydra({
    name = "Draw Utf-8 Venn Diagram",
    hint = hydra_hint,
    config = {
      color = "pink",
      invoke_on_body = true,
      hint = {
        position = "middle-right",
        float_opts = {
          border = config.border,
        },
      },
      on_enter = function()
        vim.wo.virtualedit = "all"
      end,
      on_exit = function()
        vim.wo.virtualedit = "none"
      end,
    },
    mode = { "n", "x" },
    body = "<leader>v",
    heads = {
      { "H", "<C-v>h:VBox<CR>" },
      { "J", "<C-v>j:VBox<CR>" },
      { "K", "<C-v>k:VBox<CR>" },
      { "L", "<C-v>l:VBox<CR>" },
      { "f", ":VBox<CR>", map_opts },
      { "<F5>", ":VBoxD<CR>", map_opts },
      { "<F6>", ":VBoxH<CR>", map_opts },
      { "<F7>", ":VBoxO<CR>", map_opts },
      { "<F8>", ":VBoxDO<CR>", map_opts },
      { "<F9>", ":VBoxHO<CR>", map_opts },
      { "<F10>", ":VFill<CR>", map_opts },
      { "<C-c>", nil, { exit = true, nowait = true } },
    },
  })
end)
