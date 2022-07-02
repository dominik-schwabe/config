local fn = vim.fn
local api = vim.api

local utils = require("user.utils")
local F = require("user.functional")

local curr_rg_job = nil
local Job = require("plenary.job")
local function rg(string, raw, boundry, maximum, here)
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
  local root = here and fn.expand("%:p:h") or fn.getcwd()
  curr_rg_job = Job:new({
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

local function rg_word()
  rg(vim.fn.expand("<cword>"), true, true)
end

local function rg_input()
  fn.inputsave()
  local query = fn.input("Search in files: ")
  fn.inputrestore()
  if not (query == "") then
    return rg(query, false)
  end
end

local function rg_visual()
  local selection = utils.get_visual_selection(0)
  if #selection == 0 then
    print("empty selection")
    return
  end
  rg(table.concat(selection, ""), true)
end

vim.api.nvim_create_user_command("RgWord", rg_word, {})
vim.api.nvim_create_user_command("RgInput", rg_input, {})
vim.api.nvim_create_user_command("RgVisual", rg_visual, {})

vim.keymap.set("n", "<c-_>", rg_word)
vim.keymap.set("x", "<c-_>", rg_visual)
vim.keymap.set({ "n", "x" }, "<space>x", F.f(rg, "local", true, true, 10))
vim.keymap.set("n", "_", rg_input)
