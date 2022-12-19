local F = require("user.functional")
local utils = require("user.utils")

local luasnip = F.load("luasnip")
local lspkind = F.load("lspkind")
local cmp = require("cmp")
local cmp_autopairs = F.load("nvim-autopairs.completion.cmp")

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

local mappings = {
  ["<C-w>"] = cmp.mapping.scroll_docs(-4),
  ["<C-e>"] = cmp.mapping.scroll_docs(4),
  ["<C-n>"] = function()
    if cmp.visible() then
      cmp.close()
    else
      cmp.complete()
    end
  end,
  ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
}

local jump_next = nil
local jump_prev = nil
local snippet = nil
if luasnip then
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  }

  jump_next = function()
    if luasnip.in_snippet() and luasnip.jumpable(1) then
      luasnip.jump(1)
    end
  end

  jump_prev = function()
    if luasnip.in_snippet() and luasnip.jumpable(-1) then
      luasnip.jump(-1)
    end
  end

  vim.keymap.set({ "v", "i" }, "<C-e>", jump_next)
  vim.keymap.set({ "v", "i" }, "<C-w>", jump_prev)
end

mappings["<Tab>"] = function()
  if cmp.visible() then
    cmp.select_next_item()
  else
    utils.feedkeys("<Tab>", "n")
  end
end
mappings["<S-Tab>"] = function()
  if cmp.visible() then
    cmp.select_prev_item()
  else
    utils.feedkeys("<S-Tab>", "n")
  end
end

local formatting = nil
if lspkind then
  lspkind.init({
    mode = "symbol",
    presets = "mdi",
  })
  formatting = {
    format = lspkind.cmp_format({
      with_text = false,
      maxwidth = 50,
      before = function(entry, vim_item)
        vim_item.menu = cmp_formats[entry.source.name]
        return vim_item
      end,
    }),
  }
end

cmp.setup({
  snippet = snippet,
  formatting = formatting,
  mapping = cmp.mapping.preset.insert(mappings),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "nvim_lua" },
    { name = "luasnip" },
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

if cmp_autopairs then
  cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
end
