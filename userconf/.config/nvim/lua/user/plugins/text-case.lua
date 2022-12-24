local textcase = require("textcase")

vim.keymap.set({ "n" }, "<space>u", function()
  textcase.lsp_rename("to_snake_case")
end)
vim.keymap.set({ "n" }, "<space>U", function()
  textcase.current_word("to_snake_case")
end)
vim.keymap.set({ "n" }, "<space>k", function()
  textcase.lsp_rename("to_constant_case")
end)
vim.keymap.set({ "n" }, "<space>K", function()
  textcase.current_word("to_constant_case")
end)

-- vim.keymap.set( function () textcase.current_word('to_upper_case') end
-- vim.keymap.set( function () textcase.current_word('to_lower_case') end
-- vim.keymap.set( function () textcase.current_word('to_dash_case') end
-- vim.keymap.set( function () textcase.current_word('to_dot_case') end
-- vim.keymap.set( function () textcase.current_word('to_phrase_case') end
-- vim.keymap.set( function () textcase.current_word('to_camel_case') end
-- vim.keymap.set( function () textcase.current_word('to_pascal_case') end
-- vim.keymap.set( function () textcase.current_word('to_title_case') end
-- vim.keymap.set( function () textcase.current_word('to_path_case') end
-- vim.keymap.set( function () textcase.lsp_rename('to_upper_case') end
-- vim.keymap.set( function () textcase.lsp_rename('to_lower_case') end
-- vim.keymap.set( function () textcase.lsp_rename('to_dash_case') end
-- vim.keymap.set( function () textcase.lsp_rename('to_dot_case') end
-- vim.keymap.set( function () textcase.lsp_rename('to_phrase_case') end
-- vim.keymap.set( function () textcase.lsp_rename('to_camel_case') end
-- vim.keymap.set( function () textcase.lsp_rename('to_pascal_case') end
-- vim.keymap.set( function () textcase.lsp_rename('to_title_case') end
-- vim.keymap.set( function () textcase.lsp_rename('to_path_case') end
-- vim.keymap.set( function () textcase.operator('to_upper_case') end
-- vim.keymap.set( function () textcase.operator('to_lower_case') end
-- vim.keymap.set( function () textcase.operator('to_dash_case') end
-- vim.keymap.set( function () textcase.operator('to_dot_case') end
-- vim.keymap.set( function () textcase.operator('to_phrase_case') end
-- vim.keymap.set( function () textcase.operator('to_camel_case') end
-- vim.keymap.set( function () textcase.operator('to_pascal_case') end
-- vim.keymap.set( function () textcase.operator('to_title_case') end
-- vim.keymap.set( function () textcase.operator('to_path_case') end