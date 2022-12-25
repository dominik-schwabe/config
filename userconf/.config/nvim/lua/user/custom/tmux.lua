local F = require("user.functional")

local Job = require("plenary.job")

local M = {}

local function get_tmux()
  return os.getenv("TMUX")
end

local function execute(arg, opts)
  local socket = vim.split(get_tmux(), ",")[1]
  local job = Job:new({
    command = "tmux",
    args = { "-S", socket, unpack(arg) },
    enable_recordings = true,
    writer = opts.input,
  })
  if opts.sync then
    return job:sync(500)
  end
  job:start(500)
end

local function get_version()
  local version = execute({ "-V" }, { sync = true })[1]
  version = version:match("%d+.%d+")
  version = version:gmatch("%d+")
  version = F.consume(version)
  version = F.map(version, function(e)
    return tonumber(e)
  end)
  return version
end

local redirect_to_clipboard
function M.write_clipboard(contents, regtype)
  local content = table.concat(contents, "\n")
  content = content .. (regtype == "V" and "\n" or "")
  if redirect_to_clipboard then
    execute({ "load-buffer", "-w", "-" }, { input = content })
  else
    execute({ "load-buffer", "-" }, { input = content })
  end
end

if get_tmux() ~= nil then
  local tmux_exists, version = pcall(get_version)
  if tmux_exists then
    local major, minor = unpack(version)
    redirect_to_clipboard = major > 3 or (major == 3 and minor >= 2)
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
