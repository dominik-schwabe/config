local F = require("user.functional")

local treesj = require("treesj")

local opts = {
  use_default_keymaps = false,
  check_syntax_error = true,
  cursor_behavior = "hold",
  notify = true,
  max_join_length = 100000,
}

F.load("mini.splitjoin", function(splitjoin)
  splitjoin.setup()
  local get_fallback_patterns = F.cache(function()
    local error_messages = require("treesj.notify").msg
    local fallback_message_types = { "no_configured_lang", "no_ts_parser" }
    local patterns = F.values(F.subset(error_messages, fallback_message_types))
    patterns = F.map(patterns, function(value)
      return value:gsub("%%s", ".*")
    end)
    return patterns
  end)
  opts.notify = false
  opts.on_error = function(msg, code, ...)
    local patterns = get_fallback_patterns()
    if F.any(patterns, function(pattern)
      return msg:find(pattern)
    end) then
      splitjoin.toggle()
    else
      vim.notify(string.format(msg, ...), code)
    end
  end
end)

treesj.setup(opts)

vim.keymap.set({ "n", "x" }, "Y", treesj.toggle, { desc = "toggle split join" })
