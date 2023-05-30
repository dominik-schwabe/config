local function latex_substitute()
  vim.cmd([[%s/\v\$.{-}\$/Udo/ge]])
  vim.cmd([[%s/\v\\ref\{.{-}\}/eins/ge]])
  vim.cmd([[%s/\v\\cite\{.{-}\}//ge]])
  vim.cmd([[%s/\v\\.{-}\{.{-}\}/Udo/ge]])
  vim.cmd([[%s/\v[ ]+.{-}\{.{-}\}/Udo/ge]])
  vim.cmd([[%s/\v ?\\//ge]])
  vim.cmd([[%s/\v +\././ge]])
  vim.cmd([[%s/\v +\,/,/ge]])
  vim.cmd([[%s/\v[^a-zA-Z0-9üäöß.?!(),]/ /ge]])
  vim.cmd([[%s/\v +/ /ge]])
end

vim.keymap.set("", "<space>sl", latex_substitute, { desc = "latex substitute" })
