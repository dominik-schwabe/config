local F = require("user.functional")
local U = require("user.utils")

local config = require("user.config")

require("user.completions")

local cmp = require("cmp")
local compare = require("cmp.config.compare")

local max_buffer_size = config.max_buffer_size

local function endswith(str, postfix)
  return #postfix <= #str and str:sub(#str - #postfix + 1, #str) == postfix
end

local function startswith(str, prefix)
  return #prefix <= #str and str:sub(1, #prefix) == prefix
end

local function get_description(entry)
  local completion_item = entry:get_completion_item()
  if completion_item.detail ~= "Auto-import" then
    return ""
  end
  return F.resolve(completion_item, "labelDetails", "description") or ""
end

local function compare_description(entry1, entry2)
  return #get_description(entry1) < #get_description(entry2)
end

local function compare_parameter(entry1, entry2)
  local e1 = endswith(entry1.completion_item.label, "=")
  local e2 = endswith(entry2.completion_item.label, "=")
  if e1 == e2 then
    return nil
  elseif e1 then
    return true
  else
    return false
  end
end

local cmp_options = {
  enabled = function()
    return vim.fn.reg_recording() == ""
      and vim.fn.reg_executing() == ""
      and not F.contains({ "prompt", "nofile" }, vim.bo.buftype)
  end,
  sorting = {
    comparators = {
      -- compare.offset,
      compare_parameter,
      compare.exact,
      -- compare.scopes,
      compare.score,
      compare.recently_used,
      compare.locality,
      compare.kind,
      compare.sort_text,
      compare.length,
      -- compare_description,
      compare.order,
    },
  },
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
    ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),
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
    { name = "crates" },
    { name = "luasnip", max_item_count = 3 },
    {
      name = "nvim_lsp",
      max_item_count = 50,
      entry_filter = function(entry, ctx)
        return not startswith(entry.completion_item.label, "__")
      end,
    },
    { name = "nvim_lua" },
    { name = "yank_history", max_item_count = 3 },
    { name = "async_path" },
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
    crates = "[crates]",
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

  local function find_color(entry, vim_item)
    local doc = entry:get_completion_item().documentation
    if type(doc) == "string" then
      local _, _, hex = string.find(doc, "^#(%x%x%x%x%x%x)")
      if hex then
        hex = hex:lower()
        local group = "color_" .. hex
        if vim.fn.hlID(group) < 1 then
          vim.api.nvim_set_hl(0, group, { fg = "#" .. hex })
        end
        vim_item.kind = "KnownColor"
        vim_item.kind_hl_group = group
      end
    end
  end

  local max_length = 35

  local function pyright(entry, vim_item)
    local completion_item = entry:get_completion_item()
    if completion_item.detail == "Auto-import" then
      local module = F.resolve(completion_item, "labelDetails", "description")
      if module then
        if module then
          if #module > max_length then
            module = string.sub(module, 1, max_length - 1) .. "…"
          end
          vim_item.menu = vim_item.menu .. " " .. module
          return
        end
      end
    end
  end

  local LSP_MODIFY = {
    tailwindcss = find_color,
    pyright = pyright,
    basedpyright = pyright,
  }

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
        local client_name = F.resolve(entry.source.source, "client", "name")
        if client_name then
          local modify = LSP_MODIFY[client_name]
          if modify then
            modify(entry, vim_item)
          end
        end
        return vim_item
      end,
    }),
  }
end)

cmp.setup(cmp_options)
