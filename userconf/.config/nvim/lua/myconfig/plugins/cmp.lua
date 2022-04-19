local api = vim.api

local lspkind = require("lspkind")
local luasnip = require("luasnip")
local cmp = require("cmp")

-- lspkind.setup({
--   mode = "symbol",
--   symbols = "mdi",
-- })

lspkind.init({
  mode = "symbol",
  presets = "mdi",
})

local feedkey = function(key, mode)
  api.nvim_feedkeys(api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local cmp_formats = {
  buffer = "[buf]",
  nvim_lsp = "[lsp]",
  luasnip = "[snip]",
  tmux = "[tmux]",
  nvim_lua = "[lua]",
  path = "[path]",
  rg = "[rg]",
  copilot = "[cp]",
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
  mapping = cmp.mapping.preset.insert({
    ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "s" }),
    ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "s" }),
    ["<C-n>"] = cmp.mapping(cmp.mapping.complete(), { "i" }),
    ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
    ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
  }),
  sources = cmp.config.sources({
    { name = "copilot" },
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "nvim_lua" },
    { name = "path" },
    { name = "tmux" },
    {
      name = "buffer",
      -- option = {
      --   get_bufnrs = function()
      --     return vim.api.nvim_list_bufs()
      --   end,
      -- },
    },
  }),
})

local function jump_prev()
  if luasnip and luasnip.jumpable(-1) then
    luasnip.jump(-1)
  else
    feedkey("<C-y>", "n")
  end
end

local function jump_next()
  if luasnip and luasnip.jumpable(1) then
    luasnip.jump(1)
  else
    feedkey("<C-x>", "n")
  end
end

vim.keymap.set("", "<C-y>", jump_prev, { noremap = true })
vim.keymap.set("i", "<C-y>", jump_prev, { noremap = true })
vim.keymap.set("", "<C-x>", jump_next, { noremap = true })
vim.keymap.set("i", "<C-x>", jump_next, { noremap = true })
