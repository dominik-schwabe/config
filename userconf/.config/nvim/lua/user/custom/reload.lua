local F = require("user.functional")

local function reload_config()
  F.forkey(package.loaded, function(name)
    if name:match("^user") then
      package.loaded[name] = nil
    end
  end)
  dofile(vim.env.MYVIMRC)
  vim.notify("config reloaded", "info")
end

vim.api.nvim_create_user_command("ReloadConfig", reload_config, {})
vim.keymap.set({ "n", "x" }, "<space>v", reload_config)
