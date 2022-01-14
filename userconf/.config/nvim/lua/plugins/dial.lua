local dial = require("dial")

dial.augends["custom#boolean"] = dial.common.enum_cyclic({
  name = "boolean",
  strlist = { "true", "false" },
})

dial.augends["custom#pyboolean"] = dial.common.enum_cyclic({
  name = "boolean",
  strlist = { "True", "False" },
})

dial.augends["custom#rboolean"] = dial.common.enum_cyclic({
  name = "boolean",
  strlist = { "TRUE", "FALSE" },
})

dial.config.searchlist.normal = {
  "custom#boolean",
  "custom#pyboolean",
  "custom#rboolean",
  "number#decimal#int",
  "number#hex",
  "number#binary",
  "date#[%Y/%m/%d]",
  "date#[%H:%M:%S]",
  "markup#markdown#header",
}
