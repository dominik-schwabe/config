local api = vim.api
local bo = vim.bo
local fn = vim.fn

local lspkind = require('lspkind')
local cmp = require('cmp')

lspkind.init({
  with_text = true,
  -- preset = 'codicons',
  preset = 'default',
  symbol_map = require("config").lspkind_symbol_map
})

local has_empty_before = function()
  if bo.buftype == "prompt" then
    return false
  end
  local line, col = unpack(api.nvim_win_get_cursor(0))
  return api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(0, col):match("^%s*$") ~= nil
end

local feedkey = function(key, mode)
  api.nvim_feedkeys(api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local tab = cmp.mapping(function(fallback)
  if fn.pumvisible() == 1 then
    cmp.select_next_item()
  elseif not has_empty_before() and fn["vsnip#available"]() == 1 then
    feedkey("<Plug>(vsnip-expand-or-jump)", "")
  else
    fallback()
  end
end, { "i", "s" })

local toggle_completion = cmp.mapping(function ()
  if fn.pumvisible() == 1 then
    cmp.close()
  else
    cmp.complete()
  end
end)

local s_tab = cmp.mapping(function(fallback)
  if fn.pumvisible() == 1 then
    cmp.select_prev_item()
  elseif fn["vsnip#jumpable"](-1) == 1 then
    feedkey("<Plug>(vsnip-jump-prev)", "")
  else
    fallback()
  end
end, { "i", "s" })

cmp.setup({
  snippet = {
    expand = function(args)
      fn["vsnip#anonymous"](args.body) -- For `vsnip` user.
    end
  },
  formatting = {
    format = function(entry, vim_item)
      vim_item.kind = lspkind.presets.default[vim_item.kind]
      vim_item.menu = ({
        buffer = "[Buffer]",
        nvim_lsp = "[LSP]",
        vsnip = "[Snippet]",
        tmuX = "[Tmux]",
        nvim_lua = "[Lua]",
        latex_symbols = "[Latex]",
        path = "[Path]"
      })[entry.source.name]
      return vim_item
    end
  },
  mapping = {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<Tab>'] = tab,
    ['<S-Tab>'] = s_tab,
    ['<C-Space>'] = toggle_completion,
    ['<CR>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'nvim_lua' },
    { name = 'path' },
    { name = 'tmux' },
    { name = 'vsnip' },
    { name = 'buffer', opts = {get_bufnrs = function() return api.nvim_list_bufs() end} },
    -- { name = 'latex_symbols' },
  }
})
