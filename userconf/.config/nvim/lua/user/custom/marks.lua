local F = require("user.functional")
local U = require("user.utils")

local NO_FILES = {
  "nofile",
  "quickfix",
  "terminal",
  "prompt",
}

local timer

local function is_markable_buffer(buf)
  local bufopt = vim.bo[buf]
  return bufopt.buflisted and not F.contains(NO_FILES, vim.bo[buf].buftype)
end

local function is_lower(byte)
  return 97 <= byte and byte <= 122
end

local function get_sign(sign_name)
  return vim.fn.sign_getdefined(sign_name)[1]
end

local function add_sign(bufnr, mark, line)
  local sign_name = "Marks_" .. mark
  local id = mark:byte() * 100
  if not get_sign(sign_name) then
    vim.fn.sign_define(sign_name, { text = mark, texthl = "MarkSignHL" })
  end
  vim.fn.sign_place(id, "MarkSigns", sign_name, bufnr, { lnum = line, priority = 10 })
end

local function delete_sign(bufnr, mark)
  vim.fn.sign_unplace("MarkSigns", { buffer = bufnr, id = mark:byte() * 100 })
end

local function delete_all_signs(bufnr)
  vim.fn.sign_unplace("MarkSigns", { buffer = bufnr })
end

local function delete_mark(bufnr, mark)
  if vim.api.nvim_buf_is_loaded(bufnr) then
    delete_sign(bufnr, mark)
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd("delmarks" .. " " .. mark)
    end)
  end
end

local function delete_all_marks(bufnr)
  if vim.api.nvim_buf_is_loaded(bufnr) then
    delete_all_signs(bufnr)
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd("delmarks!")
    end)
  end
end

local function get_buf_marklist(bufnr)
  return vim.api.nvim_buf_call(bufnr, function()
    local marks = vim.fn.getmarklist("%")
    F.foreach(marks, function(mark_info)
      mark_info.mark = mark_info.mark:sub(2, 2)
      mark_info.bufnr = bufnr
    end)
    marks = F.filter(marks, function(mark_info)
      return is_lower(mark_info.mark:byte())
    end)
    return marks
  end)
end

local function stop_timer()
  if timer then
    timer:stop()
    timer:close()
  end
  timer = nil
end

local function refresh()
  local buf = vim.api.nvim_get_current_buf()
  if is_markable_buffer(buf) then
    delete_all_signs(buf)
    local marklist = get_buf_marklist(buf)
    F.foreach(marklist, function(mark_info)
      add_sign(buf, mark_info.mark, mark_info.pos[2])
    end)
  end
end

local function start_timer()
  if not timer then
    timer = vim.loop.new_timer()
    timer:start(0, 1000, vim.schedule_wrap(refresh))
  end
end

local function register_mark(bufnr, mark, line)
  delete_mark(bufnr, mark)
  add_sign(bufnr, mark, line)
end

local function get_global_marklist()
  return F.concat(unpack(F.map(vim.api.nvim_list_bufs(), function(bufnr)
    return get_buf_marklist(bufnr)
  end)))
end

local function open_mark_quickfix()
  local marklist = get_global_marklist()
  marklist = F.filter_map(marklist, function(mark_info)
    if vim.api.nvim_buf_is_loaded(mark_info.bufnr) then
      local mark = mark_info.mark
      local bufnr = mark_info.bufnr
      local line = mark_info.pos[2]
      local text = U.remove_leading_space(vim.api.nvim_buf_get_lines(bufnr, line - 1, line, true)[1])
      return { bufnr = bufnr, lnum = line, col = 0, text = " -- " .. mark .. " -- : " .. text }
    end
  end)
  U.quickfix(marklist, "Marklist")
end

local function get_next_mark(bufnr)
  local marks = get_buf_marklist(bufnr)
  marks = F.map(marks, function(mark_info)
    return mark_info.mark:byte()
  end)
  table.sort(marks)
  local lowest = 97
  for _, byte in ipairs(marks) do
    if lowest ~= byte then
      return string.char(lowest)
    end
    lowest = lowest + 1
  end
  if is_lower(lowest) then
    return string.char(lowest)
  end
end

local function get_line_marks(bufnr, line)
  local marks = get_buf_marklist(bufnr)
  return F.filter_map(marks, function(mark_info)
    if mark_info.pos[2] == line then
      return mark_info.mark
    end
  end)
end

local function place_next_mark(bufnr, line)
  local next_mark = get_next_mark(bufnr)
  if next_mark ~= nil then
    register_mark(bufnr, next_mark, line)
    vim.api.nvim_buf_set_mark(bufnr, next_mark, line, 0, {})
  end
end

local function toggle_mark()
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_win_get_cursor(0)[1]

  local line_marks = get_line_marks(bufnr, line)
  if #line_marks ~= 0 then
    F.foreach(line_marks, function(mark)
      delete_mark(bufnr, mark)
    end)
  elseif is_markable_buffer(bufnr) then
    place_next_mark(bufnr, line)
  end
end

local function clear_all_marks()
  F.foreach(vim.api.nvim_list_bufs(), delete_all_marks)
end

vim.keymap.set({ "n" }, "dm", function()
  delete_all_marks(vim.api.nvim_get_current_buf())
end, { desc = "delete all marks in buffer" })
vim.keymap.set({ "n", "x" }, "m", toggle_mark, { desc = "toggle a mark on the current line" })
vim.keymap.set({ "n", "x" }, "M", open_mark_quickfix, { desc = "open quickfix with all set marks" })
vim.keymap.set({ "n" }, "dam", clear_all_marks, { desc = "delete all marks in all buffers" })

vim.api.nvim_create_augroup("UserMarks", {})
vim.api.nvim_create_autocmd("BufUnload", {
  group = "UserMarks",
  callback = function(args)
    delete_all_marks(args.buf)
  end,
})

start_timer()
