local F = require("user.functional")

local M = {}

local function get_tmux()
  return os.getenv("TMUX")
end

local function execute(arg, opts)
  local socket = vim.split(get_tmux(), ",", { trimempty = true })[1]
  local job = vim.system({ "tmux", "-S", socket, unpack(arg) }, { stdin = true, text = true, timeout = 500 })
  if opts.input ~= nil then
    job:write(opts.input)
  end
  if opts.sync then
    return vim.trim(job:wait().stdout)
  end
end

local function get_version()
  local version = execute({ "-V" }, { sync = true })
  version = version:match("%d+.%d+")
  version = version:gmatch("%d+")
  version = F.consume(version)
  version = vim.iter(version):map(tonumber):totable()
  return version
end

M.loaded = get_tmux() ~= nil
if M.loaded then
  local tmux_exists, version = pcall(get_version)
  if tmux_exists then
    local major, minor = unpack(version)
    M.version = { major, minor }
    local redirect_to_clipboard = major > 3 or (major == 3 and minor >= 2)
    function M.write_clipboard(contents, regtype)
      local content = table.concat(contents, "\n")
      content = content .. (regtype == "V" and "\n" or "")
      if redirect_to_clipboard then
        execute({ "load-buffer", "-w", "-" }, { input = content })
      else
        execute({ "load-buffer", "-" }, { input = content })
      end
    end
    vim.api.nvim_create_augroup("UserTmux", {})
    vim.api.nvim_create_autocmd("TextYankPost", {
      group = "UserTmux",
      callback = function()
        M.write_clipboard(vim.v.event.regcontents, vim.v.event.regtype)
      end,
    })
  end
end

return M
