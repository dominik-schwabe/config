local api = vim.api
local cmd = vim.cmd
local fn = vim.fn
local bo = vim.bo

local F = require("repl.functional")
local S = require("repl.store")
local CB = S.callbacks
local R = require("repl.repls")
local U = require("repl.utils")

M = {}

M.running_repls = {}

function M.find_windows_with_repl(bufnr, tab)
  local all_windows = api.nvim_list_wins()
  local windows_on_curr_tab = all_windows
  local curr_tab = api.nvim_tabpage_get_number(0)
  if tab then
    windows_on_curr_tab = F.filter(all_windows, function(winnr)
      return api.nvim_win_get_tabpage(winnr) == curr_tab
    end)
  end
  return F.filter(windows_on_curr_tab, function(winnr)
    return api.nvim_win_get_buf(winnr) == bufnr
  end)
end

function M.create_window(height, bottom)
  if bottom then
    cmd("botright new")
    api.nvim_win_set_height(0, height)
  else
    cmd("vertical botright new")
  end
end

local function create_term(ft)
  local repl_name, messages = R.find(ft, S.preferred)
  if repl_name ~= nil then
    messages[#messages + 1] = "opening '" .. repl_name .. "'"
  end
  if #messages ~= 0 then
    print(table.concat(messages, " | "))
  end
  if repl_name == nil then
    return nil
  end
  local meta = R.repls[ft][repl_name]

  local previous_window = vim.api.nvim_get_current_win()
  CB.create_window()
  local jobnr = fn.termopen(meta.command, { detach = 0 })
  local bufnr = api.nvim_win_get_buf(0)
  api.nvim_buf_set_name(bufnr, S.term_name .. "_" .. ft)
  api.nvim_buf_set_option(bufnr, "buflisted", S.listed)
  local timer = vim.loop.new_timer()
  timer:start(
    0,
    0,
    vim.schedule_wrap(function()
      vim.api.nvim_set_current_win(previous_window)
    end)
  )
  local repl = { ft = ft, jobnr = jobnr, bufnr = bufnr, meta = meta }
  api.nvim_buf_set_var(bufnr, "repl", repl)
  M.running_repls[ft] = repl
  return repl
end

local function show_term(bufnr)
  local previous_window = vim.api.nvim_get_current_win()
  CB.create_window()
  local term_window = vim.api.nvim_get_current_win()
  api.nvim_win_set_buf(term_window, bufnr)
  local timer = vim.loop.new_timer()
  timer:start(
    0,
    0,
    vim.schedule_wrap(function()
      vim.api.nvim_set_current_win(previous_window)
    end)
  )
end

local function buf_exists(bufnr)
  return bufnr ~= nil and api.nvim_buf_is_loaded(bufnr)
end

local function repl_exists(repl)
  return repl ~= nil and buf_exists(repl.bufnr)
end

local function window_exists(repl)
  local windows_with_repl = CB.find_windows_with_repl(repl.bufnr)
  return #windows_with_repl ~= 0
end

function M.open_term(ft)
  if ft == nil then
    ft = bo.ft
  end
  local repl = M.running_repls[ft]
  if repl_exists(repl) then
    if window_exists(repl) then
      return
    end
    show_term(repl.bufnr)
  else
    create_term(ft)
  end
end

function M.hide_term(ft)
  if ft == nil then
    ft = bo.ft
  end
  local repl = M.running_repls[ft]
  if repl_exists(repl) then
    local windows_with_repl = CB.find_windows_with_repl(repl.bufnr)
    F.foreach(windows_with_repl, function(winid)
      api.nvim_win_close(winid, false)
    end)
  end
end

function M.toggle_repl(ft)
  if ft == nil then
    local success, repl = pcall(api.nvim_buf_get_var, 0, "repl")
    ft = success and repl.ft or bo.ft
  end
  local repl = M.running_repls[ft]
  if repl_exists(repl) and window_exists(repl) then
    M.hide_term(ft)
  else
    M.open_term(ft)
  end
end

function M.send(ft, lines)
  if ft == nil then
    ft = bo.ft
  end
  if type(lines) == "string" then
    lines = string.gmatch(lines, "[^\n]+")
  end

  local repl = M.running_repls[ft]
  if not repl_exists(repl) then
    repl = create_term(ft)
    if repl == nil then
      return nil
    end
  end
  if S.ensure_win and not window_exists(repl) then
    show_term(repl.bufnr)
  end

  if repl.meta.preprocess ~= nil then
    lines = repl.meta.preprocess(lines)
  end
  if CB.preprocess ~= nil then
    lines = CB.preprocess(lines)
  end
  if repl.meta.format ~= nil then
    lines = repl.meta.format(lines)
  end
  if CB.format ~= nil then
    lines = CB.format(lines)
  end

  if S.debug then
    U.debug(lines)
  end

  api.nvim_chan_send(repl.jobnr, table.concat(lines, "\n"))

  local timer = vim.loop.new_timer()
  timer:start(
    0,
    0,
    vim.schedule_wrap(function()
      local windows = CB.find_windows_with_repl(repl.bufnr)
      F.foreach(windows, function(win)
        vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(repl.bufnr), 0 })
      end)
    end)
  )
end

return M
