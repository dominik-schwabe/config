local api = vim.api

local F = require("user.functional")

local luasnip_loaded, luasnip = pcall(require, "luasnip")
local lspkind_loaded, lspkind = pcall(require, "lspkind")
local cmp = require("cmp")
local cmp_autopairs = F.load("nvim-autopairs.completion.cmp")

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
if luasnip_loaded then
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  }

  jump_next = function()
    if luasnip.in_snippet() and luasnip.jumpable(1) then
      luasnip.jump(1)
    else
      feedkey("<Tab>", "n")
    end
  end

  jump_prev = function()
    if luasnip.in_snippet() and luasnip.jumpable(-1) then
      luasnip.jump(-1)
    else
      feedkey("<Tab>", "n")
    end
  end

  vim.keymap.set("v", "<Tab>", jump_next)
  vim.keymap.set("v", "<S-Tab>", jump_prev)
end

mappings["<Tab>"] = function()
  if cmp.visible() then
    cmp.select_next_item()
  else
    if jump_next then
      jump_next()
    end
  end
end
mappings["<S-Tab>"] = function()
  if cmp.visible() then
    cmp.select_prev_item()
  else
    if jump_prev then
      jump_prev()
    end
  end
end

local formatting = nil
if lspkind_loaded then
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
