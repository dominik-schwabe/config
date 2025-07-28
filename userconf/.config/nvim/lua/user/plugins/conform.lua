local apply_format = require("conform.runner").apply_format
local conform = require("conform")

local F = require("user.functional")

local formatters = require("user.config").formatters

F.foreach_items(formatters.args or {}, function(formatter, args)
  conform.formatters[formatter] = { append_args = args }
end)

local JON_OPERATORS = { "~", "=~", ":-", "unit", "::" }
local JON_ARGS = F.concat(
  {
    "--max-line-length",
    "70",
    "--spacing",
    "1",
    "--rotate-delimiters",
  },
  F.flat(F.map(JON_OPERATORS, function(op)
    return { "-o", op }
  end))
)

conform.setup({
  formatters_by_ft = formatters.filetype or {},
  formatters = {
    pestfmt = {
      command = "pestfmt",
      args = { "--stdin" },
      stdin = true,
    },
    xj = {
      command = "xj",
      args = { "--line-width", "70" },
      stdin = true,
    },
    xjl = {
      command = "xj",
      args = { "--line-width", "70", "--multiple" },
      stdin = true,
    },
    jon = {
      command = "jon",
      args = JON_ARGS,
      stdin = true,
    },
    cjon = {
      command = "jon",
      args = F.concat({
        "--multiple",
      }, JON_ARGS),
      stdin = true,
    },
    xdata = {
      command = "xdata",
      args = { "--line-width", "70" },
      stdin = true,
    },
    xdatal = {
      command = "xdata",
      args = { "--line-width", "70", "--multiple" },
      stdin = true,
    },
    cjson = {
      command = "cjson_format",
      stdin = true,
    },
  },
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
