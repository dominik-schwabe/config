local F = require("user.functional")
local U = require("user.utils")

local config = require("user.config")

require("user.completions")

local cmp = require("cmp")

local max_buffer_size = config.max_buffer_size

local cmp_options = {
  enabled = function()
    return vim.fn.reg_recording() == ""
      and vim.fn.reg_executing() == ""
      and not F.contains({ "prompt", "nofile" }, vim.bo.buftype)
  end,
  window = {
    completion = cmp.config.window.bordered({
      scrolloff = 5,
      col_offset = -3,
      winhighlight = "FloatBorder:Normal,CursorLine:Selection,Search:None",
    }),
    documentation = cmp.config.window.bordered({ scrolloff = 5, winhighlight = "" }),
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
    ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
    ["<Tab>"] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end,
    ["<S-Tab>"] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end,
  }),
  sources = cmp.config.sources({
    { name = "luasnip", max_item_count = 3 },
    { name = "nvim_lsp" },
    { name = "nvim_lua" },
    {
      name = "yank_history",
      max_item_count = 3,
    },
    { name = "async_path" },
    { name = "crates" },
    {
      name = "buffer",
      option = {
        get_bufnrs = function()
          local bufs = F.filter(vim.api.nvim_list_bufs(), function(buf)
            return vim.bo[buf].buflisted
              and vim.api.nvim_buf_is_loaded(buf)
              and not U.is_big_buffer(buf, max_buffer_size)
          end)
          return bufs
        end,
      },
      max_item_count = 3,
    },
    {
      name = "tmux",
      option = {
        all_panes = true,
      },
      max_item_count = 3,
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

  vim.keymap.set({ "v", "i" }, "<C-e>", jump_next, { desc = "jump to next position in snippet" })
  vim.keymap.set({ "v", "i" }, "<C-w>", jump_prev, { desc = "jump to previous position in snippet" })
end)

F.load("lspkind", function(lspkind)
  lspkind.init({
    mode = "symbol",
    presets = "mdi",
    symbol_map = config.icons,
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

  local cmp_hl = {
    yank_history = {
      kind = "Yank",
      kind_hl_group = "CmpItemKindYank",
    },
    path = {
      kind = "Path",
      kind_hl_group = "CmpItemKindPath",
    },
    tmux = {
      kind = "Tmux",
      kind_hl_group = "CmpItemKindTmux",
    },
  }

  local function add_tailwind_kind(entry, vim_item)
    if vim_item.kind == "Color" then -- Tailwind
      local doc = entry.completion_item.documentation
      if doc then
        local _, _, r, g, b = string.find(doc, "^rgb%((%d+), (%d+), (%d+)")
        if r then
          local color = string.format("%02x%02x%02x", r, g, b)
          local group = "tailwind_" .. color
          if vim.fn.hlID(group) < 1 then
            vim.api.nvim_set_hl(0, group, { fg = "#" .. color })
          end
          vim_item.kind = "Tailwind"
          vim_item.kind_hl_group = group
        end
      end
    end
  end

  local function map_source(entry, vim_item)
    local name = entry.source.name
    vim_item.menu = cmp_formats[name]
    local hl = cmp_hl[name]
    if hl then
      F.extend_inplace(vim_item, hl)
    end
  end

  cmp_options.formatting = {
    fields = { "kind", "abbr", "menu" },
    format = lspkind.cmp_format({
      with_text = false,
      maxwidth = 50,
      ellipsis_char = "...",
      before = function(entry, vim_item)
        map_source(entry, vim_item)
        add_tailwind_kind(entry, vim_item)
        return vim_item
      end,
    }),
  }
end)

cmp.setup(cmp_options)
