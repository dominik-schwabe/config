local api = vim.api

local lspkind = require("lspkind")
local luasnip = require("luasnip")
local cmp = require("cmp")
local cmp_autopairs = require("nvim-autopairs.completion.cmp")

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

local function jump_next()
  if luasnip.in_snippet() and luasnip.jumpable(1) then
    luasnip.jump(1)
  else
    feedkey("<Tab>", "n")
  end
end

local function jump_prev()
  if luasnip.in_snippet() and luasnip.jumpable(-1) then
    luasnip.jump(-1)
  else
    feedkey("<Tab>", "n")
  end
end

vim.keymap.set("v", "<Tab>", jump_next)
vim.keymap.set("v", "<S-Tab>", jump_prev)

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
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
    ["<C-w>"] = cmp.mapping.scroll_docs(-4),
    ["<C-e>"] = cmp.mapping.scroll_docs(4),
    ["<C-n>"] = function()
      if cmp.visible() then
        cmp.close()
      else
        cmp.complete()
      end
    end,
    ["<Tab>"] = function()
      if cmp.visible() then
        cmp.select_next_item()
      else
        jump_next()
      end
    end,
    ["<S-Tab>"] = function()
      if cmp.visible() then
        cmp.select_prev_item()
      else
        jump_prev()
      end
    end,
    ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "nvim_lua" },
    { name = "path" },
    { name = "crates" },
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

cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
