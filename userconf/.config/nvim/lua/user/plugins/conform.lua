local util = require("conform.util")
local apply_format = require("conform.runner").apply_format

local F = require("user.functional")

local formatters = require("user.config").formatters

local function extend_args(formatter, args)
  local format_definition = require("conform.formatters." .. formatter)
  local extra = {
    args = util.extend_args(format_definition.args, args, { append = true }),
  }
  if format_definition.range_args then
    extra.range_args = util.extend_args(format_definition.range_args, args, { append = true })
  end
  require("conform").formatters[formatter] = vim.tbl_deep_extend("force", format_definition, extra)
end

F.foreach_items(formatters.args or {}, extend_args)

local conform = require("conform")
conform.setup({
  formatters_by_ft = formatters.filetype or {},
})

local function format()
  conform.format({
    async = true,
    lsp_fallback = true,
    filter = function(client)
      return F.contains(formatters.clients, client.name)
    end,
  })
end

vim.keymap.set({ "n", "x" }, "<space>f", format, { silent = true, desc = "format buffer" })

local function trim_whitespace()
  local buf = vim.api.nvim_get_current_buf()
  local bo = vim.bo[buf]
  if not bo.modifiable or bo.readonly then
    vim.notify("not modifiable")
    return
  end
  local original_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local new_lines = F.copy(original_lines)
  if bo.filetype ~= "markdown" then
    new_lines = F.map(new_lines, function(line)
      return line:gsub("%s+$", "")
    end)
  else
    vim.notify("skip trimming for markdown")
  end
  local end_index = #new_lines
  while end_index > 0 and new_lines[end_index] == "" do
    new_lines[end_index] = nil
    end_index = end_index - 1
  end
  apply_format(buf, original_lines, new_lines)
end

vim.api.nvim_create_user_command("TrimWhitespace", trim_whitespace, {})
vim.keymap.set({ "n", "x" }, "<space>.", trim_whitespace, { desc = "trim whitespace and last empty lines" })
