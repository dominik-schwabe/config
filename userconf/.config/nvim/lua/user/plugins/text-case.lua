local config = require("user.config")

local textcase = require("textcase")

local function lsp_to_snake_case()
  textcase.lsp_rename("to_snake_case")
end
local function lsp_to_constant_case()
  textcase.lsp_rename("to_constant_case")
end
local function lsp_to_camel_case()
  textcase.lsp_rename("to_camel_case")
end
local function lsp_to_pascal_case()
  textcase.lsp_rename("to_pascal_case")
end

local function to_snake_case()
  textcase.current_word("to_snake_case")
end
local function to_constant_case()
  textcase.current_word("to_constant_case")
end
local function to_camel_case()
  textcase.current_word("to_camel_case")
end
local function to_pascal_case()
  textcase.current_word("to_pascal_case")
end

local hydra_hint = [[
_<F9>_  : to-snake-case (LSP)
_<F10>_ : TO-CONSTANT-CASE (LSP)
_<F11>_ : toCamelCase (LSP)
_<F12>_ : ToPascalCase (LSP)
_<F5>_  : to-snake-case
_<F6>_  : TO-CONSTANT-CASE
_<F7>_  : toCamelCase
_<F8>_  : ToPascalCase
_<C-c>_ : exit
]]

local Hydra = require("hydra")

Hydra({
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
  },
  name = "textcase",
  mode = { "n", "x" },
  body = "<space>cc",
  heads = {
    { "<F5>", to_snake_case, { silent = true, nowait = true } },
    { "<F6>", to_constant_case, { silent = true, nowait = true } },
    { "<F7>", to_camel_case, { silent = true, nowait = true } },
    { "<F8>", to_pascal_case, { silent = true, nowait = true } },
    { "<F9>", lsp_to_snake_case, { silent = true, nowait = true } },
    { "<F10>", lsp_to_constant_case, { silent = true, nowait = true } },
    { "<F11>", lsp_to_camel_case, { silent = true, nowait = true } },
    { "<F12>", lsp_to_pascal_case, { silent = true, nowait = true } },
    { "<C-c>", nil, { exit = true, nowait = true } },
  },
})
-- vim.keymap.set("<space>ac", textcase_hydra:activate, {})

-- vim.keymap.set(function() textcase.current_word('to_upper_case') end
-- vim.keymap.set(function() textcase.current_word('to_lower_case') end
-- vim.keymap.set(function() textcase.current_word('to_dash_case') end
-- vim.keymap.set(function() textcase.current_word('to_dot_case') end
-- vim.keymap.set(function() textcase.current_word('to_phrase_case') end
-- vim.keymap.set(function() textcase.current_word('to_camel_case') end
-- vim.keymap.set(function() textcase.current_word('to_pascal_case') end
-- vim.keymap.set(function() textcase.current_word('to_title_case') end
-- vim.keymap.set(function() textcase.current_word('to_path_case') end
-- vim.keymap.set(function() textcase.lsp_rename('to_upper_case') end
-- vim.keymap.set(function() textcase.lsp_rename('to_lower_case') end
-- vim.keymap.set(function() textcase.lsp_rename('to_dash_case') end
-- vim.keymap.set(function() textcase.lsp_rename('to_dot_case') end
-- vim.keymap.set(function() textcase.lsp_rename('to_phrase_case') end
-- vim.keymap.set(function() textcase.lsp_rename('to_camel_case') end
-- vim.keymap.set(function() textcase.lsp_rename('to_pascal_case') end
-- vim.keymap.set(function() textcase.lsp_rename('to_title_case') end
-- vim.keymap.set(function() textcase.lsp_rename('to_path_case') end
-- vim.keymap.set(function() textcase.operator('to_upper_case') end
-- vim.keymap.set(function() textcase.operator('to_lower_case') end
-- vim.keymap.set(function() textcase.operator('to_dash_case') end
-- vim.keymap.set(function() textcase.operator('to_dot_case') end
-- vim.keymap.set(function() textcase.operator('to_phrase_case') end
-- vim.keymap.set(function() textcase.operator('to_camel_case') end
-- vim.keymap.set(function() textcase.operator('to_pascal_case') end
-- vim.keymap.set(function() textcase.operator('to_title_case') end
-- vim.keymap.set(function() textcase.operator('to_path_case') end
