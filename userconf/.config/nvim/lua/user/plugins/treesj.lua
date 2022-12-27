local treesj = require("treesj")
local tsj_utils = require("treesj.langs.utils")

local langs = {
  python = {
    dictionary = tsj_utils.set_preset_for_dict({
      join = { space_in_brackets = false },
    }),
    list = tsj_utils.set_preset_for_list({
      join = { space_in_brackets = false },
    }),
    argument_list = tsj_utils.set_preset_for_args(),
    parameters = tsj_utils.set_preset_for_args(),
    tuple = tsj_utils.set_preset_for_args(),
    list_comprehension = tsj_utils.set_preset_for_list({
      join = { space_in_brackets = false },
    }),
    set = tsj_utils.set_preset_for_list({
      join = { space_in_brackets = false },
    }),
  },
  rust = {
    parameters = tsj_utils.set_preset_for_args(),
    type_arguments = tsj_utils.set_preset_for_args(),
    arguments = tsj_utils.set_preset_for_args(),
    tuple_expression = tsj_utils.set_preset_for_args(),
  }
}

treesj.setup({
  use_default_keymaps = false,
  check_syntax_error = true,
  cursor_behavior = "hold",
  notify = true,
  max_join_length = 100000,
  langs = langs,
})
