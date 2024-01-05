local o = vim.o
local opt = vim.opt

local F = require("user.functional")

local function set_spell(lang)
  if lang == nil or (o.spelllang == lang and o.spell) then
    opt.spell = false
    vim.notify("nospell")
  else
    opt.spelllang = lang
    opt.spell = true
    vim.notify("language: " .. lang)
  end
end

vim.api.nvim_create_user_command("SetSpell", function(arg)
  set_spell(arg.fargs[1])
end, { nargs = "*" })

local set_spell_cb = F.f(set_spell)

vim.keymap.set({ "n", "x" }, "<space>ss", set_spell_cb(nil), { desc = "disable spell" })
vim.keymap.set({ "n", "x" }, "<space>sd", set_spell_cb("de_de"), { desc = "toggle spell German" })
vim.keymap.set({ "n", "x" }, "<space>se", set_spell_cb("en_us"), { desc = "toggle spell English" })
