local F = require("user.functional")

require("luasnip.loaders.from_vscode").lazy_load()

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

local opts = {
  history = true,
  delete_check_events = "InsertLeave",
}

F.load("luasnip_snippets.common.snip_utils", function(snip_utils)
  snip_utils.setup()
  opts = F.extend(opts, F.subset(snip_utils, { "load_ft_func", "ft_func" }))
end)

ls.setup(opts)
local extensions = {
  javascript = { "html" },
  typescript = { "html" },
  javascriptreact = { "html" },
  typescriptreact = { "html" },
  markdown = { "license" },
  text = { "license" },
}
F.foreach_items(extensions, ls.filetype_extend)

local ATTR_KEYWORDS = {
  ["~"] = { "size", "condition", "example", "creator" },
  ["=~"] = { "amount" },
  [":-"] = {
    "attribute",
    "heater",
    "timing",
    "frequency",
    "form",
    "container",
    "theme",
    "target",
    "heat",
    "method",
    "setting",
    "along",
    "duration",
    "until",
    "speed",
    "ensure",
    "manner",
  },
}

local LABEL_SNIPPETS = F.concat(
  F.flat(F.map(F.entries(ATTR_KEYWORDS), function(pair)
    local operator, names = unpack(pair)
    return F.map(names, function(name)
      return s(name, { t(name), t(" "), t(operator), t(" [ "), i(1), t(" ] ,") })
    end)
  end)),
  {
    s("that:source", { t("source"), t(" "), t("~"), t(" [ "), i(1), t(" ] ,") }),
    s("mode:source", { t("source"), t(" "), t(":-"), t(" [ "), i(1), t(" ] ,") }),
    s("transform", { t("transform"), t(" =~ [ undergo ( "), i(1), t(" ) ] ,") }),
    s("parallel", { t("parallel"), t(" :- [ do ( "), i(1), t(" ) ] ,") }),
    s("do", { t("do [ "), i(1), t(" ] mode [ "), i(2), t(" ]") }),
    s("class", { t("class [ "), i(1), t(" ] tag [ "), i(2), t(" ]") }),
    s("food", { t("class [ food, "), i(1), t(" ] that [ "), i(2), t(" ] tag [ "), i(3), t(" ]") }),
    s("filter", { i(1), t(" ~ [ "), i(2), t(" ] ,") }),
    s("mod", { i(1), t(" =~ [ "), i(2), t(" ] ,") }),
    s("arg", { i(1), t(" :- [ "), i(2), t(" ] ,") }),
    s("yield", { t("yield [ key { result } tag { "), i(1), t(" } ]") }),
    s("tag", { t("tag [ "), i(1), t(" ]") }),
    s("mode", { t("mode [ "), i(1), t(" ]") }),
    s("oven", { t("class ( oven ) tag ( oven )") }),
  }
)

ls.add_snippets("jon", LABEL_SNIPPETS)
ls.add_snippets("cjon", LABEL_SNIPPETS)
