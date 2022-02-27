local augend = require("dial.augend")

require("dial.config").augends:register_group({
  default = {
    augend.constant.new({
      elements = { "true", "false" },
      word = true,
      cyclic = true,
    }),
    augend.constant.new({
      elements = { "True", "False" },
      word = true,
      cyclic = true,
    }),
    augend.constant.new({
      elements = { "TRUE", "FALSE" },
      word = true,
      cyclic = true,
    }),
    augend.constant.new({
      elements = { "[ ]", "[x]" },
      word = false,
      cyclic = true,
    }),
    augend.integer.alias.decimal,
    augend.integer.alias.hex,
    augend.integer.alias.binary,
    augend.date.alias["%Y/%m/%d"],
    augend.date.alias["%H:%M:%S"],
  },
})