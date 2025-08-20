local config = require("user.config")

local blink = require("blink.cmp")

blink.setup({
  keymap = {
    preset = "default",
    ["<C-n>"] = {
      function(cmp)
        if cmp.is_menu_visible() then
          cmp.cancel()
          return cmp.hide()
        else
          return cmp.show()
        end
      end,
    },
    ["<CR>"] = { "accept", "fallback" },
    ["<Tab>"] = { "select_next", "fallback" },
    ["<S-Tab>"] = { "select_prev", "fallback" },
    ["<C-w>"] = { "scroll_documentation_up", "fallback" },
    ["<C-e>"] = { "scroll_documentation_down", "fallback" },
  },
  appearance = { nerd_font_variant = "mono" },
  completion = {
    list = { selection = { preselect = true, auto_insert = false } },
    trigger = {
      show_on_backspace = false,
      show_on_insert = false,
    },
    documentation = {
      auto_show = true,
      window = { border = config.border },
    },
    menu = {
      border = config.border,
      scrolloff = 9999,
      draw = {
        padding = { 0, 1 },
        columns = { { "kind_icon", gap = 1 }, { "label", "label_description", gap = 1 }, { "source_name" } },
        components = {
          kind_icon = {
            text = function(ctx)
              local icon = ctx.kind_icon
              local overwrite = config.icons[ctx.kind]
              if ctx.kind ~= "Color" and overwrite then
                icon = overwrite
              end
              return icon .. ctx.icon_gap
            end,
          },
        },
      },
    },
  },
  signature = { window = { border = config.border } },
  fuzzy = { implementation = "prefer_rust_with_warning" },
  enabled = function()
    return vim.fn.reg_recording() == ""
      and vim.fn.reg_executing() == ""
      and not vim.tbl_contains({ "prompt", "nofile" }, vim.bo.buftype)
  end,
  sources = {
    default = { "lsp", "path", "snippets", "buffer", "tmux" },
    providers = {
      lsp = {
        name = "[lsp]",
        max_items = 50,
        transform_items = function(ctx, items)
          if not (ctx.line:find("[.%s]_[a-zA-Z0-9_]*$") or ctx.line:find("^_[a-zA-Z0-9_]*$")) then
            items = vim
              .iter(items)
              :filter(function(item)
                return not item.label:find("^_[a-zA-Z0-9]")
              end)
              :totable()
          end
          if not (ctx.line:find("[.%s]__[a-zA-Z0-9_]*$") or ctx.line:find("^__[a-zA-Z0-9_]*$")) then
            items = vim
              .iter(items)
              :filter(function(item)
                return not item.label:find("^__[a-zA-Z0-9]")
              end)
              :totable()
          end
          return items
        end,
      },
      snippets = {
        name = "[snip]",
        max_items = 3,
        should_show_items = function(ctx)
          return ctx.trigger.initial_kind ~= "trigger_character"
        end,
      },
      buffer = {
        name = "[buf]",
        max_items = 3,
        opts = {
          get_bufnrs = function()
            return vim
              .iter(vim.api.nvim_list_bufs())
              :filter(function(buf)
                return vim.bo[buf].buflisted and vim.api.nvim_buf_is_loaded(buf)
              end)
              :totable()
          end,
        },
        score_offset = -20,
      },
      path = {
        name = "[path]",
      },
      tmux = {
        module = "blink-cmp-tmux",
        name = "[tmux]",
        max_items = 3,
        opts = {
          all_panes = true,
        },
        score_offset = -20,
      },
    },
  },
})
