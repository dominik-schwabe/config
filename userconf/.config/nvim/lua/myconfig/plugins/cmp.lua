local api = vim.api
local map = api.nvim_set_keymap

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
