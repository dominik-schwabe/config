local function set_cwd()
  vim.cmd("cd %:p:h")
end

vim.keymap.set("n", "<space>cw", set_cwd)
