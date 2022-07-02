local o = vim.o
local opt = vim.opt

local F = require("user.functional")

local function set_spell(lang)
  if lang == nil or (o.spelllang == lang and o.spell) then
    opt.spell = false
    print("nospell")
  else
    opt.spelllang = lang
    opt.spell = true
    print("language: " .. lang)
  end
end

vim.api.nvim_create_user_command("SetSpell", function(arg)
  set_spell(arg.fargs[1])
end, { nargs = "*" })

vim.keymap.set({ "n", "x" }, "<space>ss", F.f(set_spell, nil))
vim.keymap.set({ "n", "x" }, "<space>sd", F.f(set_spell, "de_de"))
vim.keymap.set({ "n", "x" }, "<space>se", F.f(set_spell, "en_us"))
