local F = require("user.functional")

require("luasnip.loaders.from_vscode").lazy_load()

local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local extras = require("luasnip.extras")
local l = extras.lambda
local rep = extras.rep
local p = extras.partial
local m = extras.match
local n = extras.nonempty
local dl = extras.dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local conds = require("luasnip.extras.expand_conditions")
local postfix = require("luasnip.extras.postfix").postfix
local types = require("luasnip.util.types")
local parse = require("luasnip.util.parser").parse_snippet
local ms = ls.multi_snippet
local k = require("luasnip.nodes.key_indexer").new_key

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
local LABEL_SNIPPETS = {
  s("optional", { t('{"optional": '), i(1), t("}") }),
  s("one", { t('{"one": ['), i(1), t("]}") }),
  s("any", { t('{"any": ['), i(1), t("]}") }),
  s("all", { t('{"all": ['), i(1), t("]}") }),
  s("+", { t("["), i(1), t(', "+", '), i(2), t("]") }),
  s("*", { t("["), i(1), t(', "*", '), i(2), t("]") }),
  s("-", { t("["), i(1), t(', "-", '), i(2), t("]") }),
  s(":", { t("["), i(1), t(', "/", '), i(2), t("]") }),
  s("to", { t("["), i(1), t(', "to", '), i(2), t("]") }),
  s("taste", { t('"to taste"') }),
  s("desired", { t('"as desired"') }),
  s("needed", { t('"as needed"') }),
  s("name", { t('"name": "'), i(1), t('"') }),
  s("ingredient_choices", { t('"choices": ["'), i(1), t('"]') }),
  s("amount", { t('"amount": {'), i(1), t("}") }),
  s("taste", { t('"taste": ["'), i(1), t('"]') }),
  s("condition", { t('"condition": ["'), i(1), t('"]') }),
  s("preparation", { t('"preparation": ["'), i(1), t('"]') }),
  s("comments", { t('"comments": ["'), i(1), t('"]') }),
  s("quantity", { t('"quantity": ') }),
  s("attributes", { t('"attributes": {"'), i(1), t('"}') }),
  s("unit", { t('"unit": "'), i(1), t('"') }),
  s("size", { t('"size": "'), i(1), t('"') }),
  s("start", {
    t('{"amount": {"quantity": '),
    i(1),
    t(', "unit": "'),
    i(2),
    t('"}, "name": "'),
    i(3),
    t('"}'),
  }),
  s("half", { t('[1, "/", 2]') }),
  s("third", { t('[1, "/", 3]') }),
  s("quarter", { t('[1, "/", 4]') }),
  s("three_quarter", { t('[3, "/", 4]') }),
  s("inner_amount", {
    t('{"quantity": '),
    i(1),
    t(', "unit": "'),
    i(2),
    t('"}'),
  }),
}
ls.add_snippets("json", LABEL_SNIPPETS)
ls.add_snippets("jsonl", LABEL_SNIPPETS)
