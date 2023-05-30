local U = require("user.utils")
local F = require("user.functional")

local curr_rg_job = nil

local function rg(string, opt)
  opt = opt or {}

  local raw = opt.raw
  local boundry = opt.boundry
  local maximum = opt.maximum
  local here = opt.here

  if string == "" then
    return
  end
  if curr_rg_job ~= nil then
    curr_rg_job:shutdown()
  end
  local args = {
    "--color=never",
    "--ignore-case",
    "--with-filename",
    "--no-heading",
    "--vimgrep",
    "--max-filesize=1M",
  }
  if raw then
    string = vim.fn.escape(string, "^$.*+?()[]{}|")
  end
  if maximum then
    maximum = maximum - 1
  end
  if boundry then
    string = "\\b" .. string .. "\\b"
  end
  args[#args + 1] = string
  local root
  if here then
    root = vim.fn.expand("%:p:h")
    vim.cmd("cd " .. root)
  else
    root = vim.fn.getcwd()
  end
  curr_rg_job = require("plenary.job"):new({
    command = "rg",
    args = args,
    interactive = false,
    cwd = root,
    maximum_results = maximum,
    on_exit = function(j, return_val)
      if return_val == 0 then
        vim.schedule_wrap(function()
          args[#args] = '"' .. vim.fn.escape(args[#args], '"') .. '"'
          local command = "rg " .. table.concat(args, " ")
          local lines = j:result()
          if #lines == 0 then
            vim.notify("nothing found")
          else
            U.quickfix(lines, command)
          end
        end)()
      else
        vim.schedule_wrap(function()
          local lines = j:stderr_result()
          if #lines == 0 then
            vim.notify("nothing was returned")
          else
            vim.notify(table.concat(lines, "\n"), vim.log.levels.ERROR)
          end
        end)()
      end
    end,
  })
  curr_rg_job:start()
end

local function _rg_word(here)
  rg(vim.fn.expand("<cword>"), { raw = true, boundry = true, here = here })
end

local function _rg_visual(here)
  local selection = U.get_visual_selection(0)
  if #selection == 0 then
    vim.notify("empty selection")
    return
  end
  rg(table.concat(selection, ""), { raw = true, here = here })
end

vim.keymap.set("n", "<space>-", F.f(_rg_word, false), { desc = "search for word in files" })
vim.keymap.set("x", "<space>-", F.f(_rg_visual, false), { desc = "search for visual selection in files" })
vim.keymap.set("n", "<space>_", F.f(_rg_word, true), { desc = "search for word in files from current file" })
vim.keymap.set("x", "<space>_", F.f(_rg_visual, true), { desc = "search for visual selection from current file" })

-- local function rg_input()
--   vim.ui.input({ prompt = "Search in files: : " }, function(query)
--     if query then
--       rg(query)
--     end
--   end)
-- end

-- vim.keymap.set("n", "_", rg_input)
