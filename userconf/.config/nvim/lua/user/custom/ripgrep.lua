local fn = vim.fn
local api = vim.api

local utils = require("user.utils")
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
    "--ignore-file",
    ".gitignore",
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
    root = fn.expand("%:p:h")
    vim.cmd("cd " .. root)
  else
    root = fn.getcwd()
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
            vim.notify("nothing found", "ERR")
          else
            vim.fn.setqflist({}, "r", { title = command, lines = lines })
            api.nvim_command("botright copen")
          end
        end)()
      else
        vim.schedule_wrap(function()
          local lines = j:stderr_result()
          if #lines == 0 then
            vim.notify("nothing was returned", "ERR")
          else
            vim.notify(table.concat(lines, "\n"), "ERR")
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

local function rg_input()
  fn.inputsave()
  local query = fn.input("Search in files: ")
  fn.inputrestore()
  if not (query == "") then
    return rg(query)
  end
end

local function _rg_visual(here)
  local selection = utils.get_visual_selection(0)
  if #selection == 0 then
    print("empty selection")
    return
  end
  rg(table.concat(selection, ""), { raw = true, here = here })
end

local rg_word = F.f(_rg_word, false)
local rg_word_here = F.f(_rg_word, true)
local rg_visual = F.f(_rg_visual, false)
local rg_visual_here = F.f(_rg_visual, true)

vim.api.nvim_create_user_command("RgWord", rg_word, {})
vim.api.nvim_create_user_command("RgWordHere", rg_word_here, {})
vim.api.nvim_create_user_command("RgInput", rg_input, {})
vim.api.nvim_create_user_command("RgVisual", rg_visual, {})
vim.api.nvim_create_user_command("RgVisualHere", rg_visual_here, {})

vim.keymap.set("n", "<space>-", rg_word)
vim.keymap.set("x", "<space>-", rg_visual)
vim.keymap.set("n", "<space>_", rg_word_here)
vim.keymap.set("x", "<space>_", rg_visual_here)
vim.keymap.set({ "n", "x" }, "<space>x", F.f(rg, "local", true, true, 10))
vim.keymap.set("n", "_", rg_input)
