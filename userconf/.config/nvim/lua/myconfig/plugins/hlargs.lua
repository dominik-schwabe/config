require("hlargs").setup({
  color = "#00ffaf",
  excluded_argnames = {
    declarations = {},
    usages = {
      python = { "self", "cls" },
      lua = { "self" },
    },
  },
}) -- "#5fafff" "#04c99b" "#02b4ef"
