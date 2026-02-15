local U = require("user.utils")

local curr_rg_job = nil

local function parse_line(line)
  local _, _, filename, lnum, col, text = string.find(line, [[(..-):(%d+):(%d+):(.*)]])
  return {
    line = line,
    filename = filename,
    lnum = tonumber(lnum),
    col = tonumber(col),
    text = text,
  }
end

local function sort_rg_matches(lines)
  lines = vim.iter(lines):map(parse_line):totable()
  table.sort(lines, function(a, b)
    if a.filename == b.filename then
      if a.lnum == b.lnum then
        return a.col < b.col
      end
      return a.lnum < b.lnum
    end
    return a.filename < b.filename
  end)
  lines = vim
    .iter(lines)
    :map(function(entry)
      return entry.line
    end)
    :totable()
  return lines
end

local function rg(string, opt)
  opt = opt or {}

  local raw = opt.raw
  local boundary = opt.boundary
  local timeout = opt.timeout

  if string == "" then
    return
  end
  if curr_rg_job ~= nil then
    curr_rg_job:kill()
  end
  local args = {
    "--color=never",
    "--no-heading",
    "--with-filename",
    "--ignore-case",
    "--vimgrep",
    "--max-columns=1000",
  }
  local cwd = vim.fn.getcwd()
  if U.is_git_ignored(cwd) then
    args[#args + 1] = "--no-ignore"
  end
  if raw then
    -- don't use "--fixed-strings" because else boundary does not work
    string = vim.fn.escape(string, "^$.*+?()[]{}|\\-")
  end
  if boundary then
    string = "\\b" .. string .. "\\b"
  end
  args[#args + 1] = string
  curr_rg_job = vim.system({ "rg", unpack(args) }, {
    cwd = cwd,
    text = true,
    timeout = timeout,
  }, function(obj)
    if obj.code == 0 or obj.code == 124 then
      vim.schedule(function()
        args[#args] = '"' .. vim.fn.escape(args[#args], '"') .. '"'
        local command = "rg " .. table.concat(args, " ")
        local lines = vim.split(obj.stdout, "\n", { trimempty = true })
        if obj.code == 124 then
          vim.schedule(function()
            vim.notify(string.format("timeout reached (%d ms)", timeout), vim.log.levels.WARN)
          end)
        end
        if #lines == 0 then
          vim.notify("nothing found")
        else
          lines = sort_rg_matches(lines)
          U.quickfix(lines, command)
        end
      end)
    else
      vim.schedule(function()
        local output = obj.stderr == "" and "no output" or "stderr: " .. obj.stderr
        local code = opt.code ~= nil and tonumber(opt.code) or "?"
        vim.notify(string.format("job failed (%s) %s", code, output), vim.log.levels.ERROR)
      end)
    end
  end)
end

local function _rg()
  if vim.fn.mode() == "v" then
    local selection = U.get_visual_selection(0)
    rg(table.concat(selection, ""), { raw = true, timeout = 1000 })
  else
    rg(vim.fn.expand("<cword>"), { raw = true, boundary = true, timeout = 1000 })
  end
end

vim.keymap.set({ "n", "x" }, "<space>-", _rg, { desc = "Visual selection or word" })
