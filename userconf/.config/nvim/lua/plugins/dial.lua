local dial = require("dial")

dial.augends["custom#boolean"] = dial.common.enum_cyclic({
  name = "boolean",
  strlist = { "true", "false" },
})

dial.augends["custom#pyboolean"] = dial.common.enum_cyclic({
  name = "boolean",
  strlist = { "True", "False" },
})

dial.config.searchlist.normal = {
  "custom#boolean",
  "custom#pyboolean",
  "number#decimal#int",
  "number#hex",
  "number#binary",
  "date#[%Y/%m/%d]",
  "date#[%H:%M:%S]",
  "markup#markdown#header",
}
