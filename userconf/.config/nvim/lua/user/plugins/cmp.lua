local F = require("user.functional")
local utils = require("user.utils")

require("user.completions")

local cmp = require("cmp")

local cmp_options = {
  enabled = function()
    return vim.bo.buftype ~= "prompt" and vim.bo.buftype ~= "nofile"
  end,
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
    ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
    ["<Tab>"] = function()
      if cmp.visible() then
        cmp.select_next_item()
      else
        utils.feedkeys("<Tab>", "n")
      end
    end,
    ["<S-Tab>"] = function()
      if cmp.visible() then
        cmp.select_prev_item()
      else
        utils.feedkeys("<S-Tab>", "n")
      end
    end,
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "nvim_lua" },
    -- { name = "luasnip" },
    { name = "yank_history" },
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
}

F.load("luasnip", function(luasnip)
  cmp_options.snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  }

  local jump_next = function()
    if luasnip.in_snippet() and luasnip.jumpable(1) then
      luasnip.jump(1)
    end
  end

  local jump_prev = function()
    if luasnip.in_snippet() and luasnip.jumpable(-1) then
      luasnip.jump(-1)
    end
  end

  vim.keymap.set({ "v", "i" }, "<C-e>", jump_next)
  vim.keymap.set({ "v", "i" }, "<C-w>", jump_prev)
end)

F.load("lspkind", function(lspkind)
  lspkind.init({
    mode = "symbol",
    presets = "mdi",
  })

  local cmp_formats = {
    buffer = "[buf]",
    nvim_lsp = "[lsp]",
    luasnip = "[snip]",
    tmux = "[tmux]",
    nvim_lua = "[lua]",
    path = "[path]",
    rg = "[rg]",
    copilot = "[cp]",
    yank_history = "[yank]",
  }

  cmp_options.formatting = {
    format = lspkind.cmp_format({
      with_text = false,
      maxwidth = 50,
      before = function(entry, vim_item)
        vim_item.menu = cmp_formats[entry.source.name]
        return vim_item
      end,
    }),
  }
end)

cmp.setup(cmp_options)

F.load("nvim-autopairs.completion.cmp", function(cmp_autopairs)
  cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
end)
