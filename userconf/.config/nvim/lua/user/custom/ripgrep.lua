local config = require("user.config")

local F = require("user.functional")
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
  lines = F.map(lines, parse_line)
  table.sort(lines, function(a, b)
    if a.filename == b.filename then
      if a.lnum == b.lnum then
        return a.col < b.col
      end
      return a.lnum < b.lnum
    end
    return a.filename < b.filename
  end)
  lines = F.map(lines, function(entry)
    return entry.line
  end)
  return lines
end

local function rg(string, opt)
  opt = opt or {}

  local raw = opt.raw
  local boundary = opt.boundary
  local maximum = opt.maximum

  if string == "" then
    return
  end
  if curr_rg_job ~= nil then
    curr_rg_job:shutdown()
  end
  local args = {
    "--color=never",
    "--no-heading",
    "--with-filename",
    "--ignore-case",
    "--vimgrep",
    -- "--max-filesize=1M",
    "--max-columns=1000",
  }
  if raw then
    string = vim.fn.escape(string, "^$.*+?()[]{}|\\-") -- don't use "--fixed-strings" because else boundary does not work
  end
  if maximum then
    maximum = maximum - 1
  end
  if boundary then
    string = "\\b" .. string .. "\\b"
  end
  args[#args + 1] = string
  curr_rg_job = require("plenary.job"):new({
    command = "rg",
    args = args,
    interactive = false,
    cwd = vim.fn.getcwd(),
    maximum_results = maximum,
    on_exit = function(j, return_val)
      if return_val == 0 or return_val == nil then
        vim.schedule(function()
          args[#args] = '"' .. vim.fn.escape(args[#args], '"') .. '"'
          local command = "rg " .. table.concat(args, " ")
          local lines = j:result()
          if return_val == nil then
            vim.schedule(function()
              vim.notify(string.format("limit reached (%d)", opt.maximum), vim.log.levels.WARN)
            end)
          elseif #lines == 0 then
            vim.notify("nothing found")
          end
          if #lines ~= 0 then
            lines = sort_rg_matches(lines)
            U.quickfix(lines, command)
          end
        end)
      else
        vim.schedule(function()
          local lines = j:stderr_result()
          if #lines == 0 then
            vim.notify("job failed without output", vim.log.levels.ERROR)
          else
            vim.notify(table.concat(lines, "\n"), vim.log.levels.ERROR)
          end
        end)
      end
    end,
  })
  curr_rg_job:start()
end

local function _rg()
  if vim.fn.mode() == "v" then
    local selection = U.get_visual_selection(0)
    rg(table.concat(selection, ""), { raw = true, maximum = config.rg_maximum_lines })
  else
    rg(vim.fn.expand("<cword>"), { raw = true, boundary = true, maximum = config.rg_maximum_lines })
  end
end

vim.keymap.set({ "n", "x" }, "<space>-", _rg, { desc = "search for word or selection in files" })
