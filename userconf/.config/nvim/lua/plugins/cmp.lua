local api = vim.api
local bo = vim.bo
local fn = vim.fn
local map = api.nvim_set_keymap

local lspkind = require("lspkind")
local luasnip = require("luasnip")
local cmp = require("cmp")

lspkind.init({
  mode = "symbol",
  -- preset = 'codicons',
  preset = "default",
  symbol_map = require("config").lspkind_symbol_map,
})

local feedkey = function(key, mode)
  api.nvim_feedkeys(api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local cmp_formats = {
  buffer = "[Buffer]",
  nvim_lsp = "[LSP]",
  luasnip = "[Snippet]",
  tmux = "[Tmux]",
  nvim_lua = "[Lua]",
  latex_symbols = "[Latex]",
  path = "[Path]",
}

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  formatting = {
    format = lspkind.cmp_format({
      with_text = false,
      maxwidth = 50,
      before = function(entry, vim_item)
        vim_item.menu = cmp_formats[entry.source.name]
        return vim_item
      end,
    }),
  },
  mapping = {
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
    ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
  },
  sources = {
    { name = "luasnip" },
    { name = "nvim_lsp" },
    { name = "nvim_lua" },
    { name = "path" },
    { name = "tmux" },
    { name = "buffer" },
  },
})

function JumpPrev()
  if luasnip and luasnip.jumpable(-1) then
    luasnip.jump(-1)
  else
    feedkey("<C-y>", "n")
  end
end

function JumpNext()
  if luasnip and luasnip.jumpable(1) then
    luasnip.jump(1)
  else
    feedkey("<C-x>", "n")
  end
end

map("", "<C-y>", "<CMD>lua JumpPrev()<CR>", { noremap = true })
map("i", "<C-y>", "<CMD>lua JumpPrev()<CR>", { noremap = true })
map("", "<C-x>", "<CMD>lua JumpNext()<CR>", { noremap = true })
map("i", "<C-x>", "<CMD>lua JumpNext()<CR>", { noremap = true })
