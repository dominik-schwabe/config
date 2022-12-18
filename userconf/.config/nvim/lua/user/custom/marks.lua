local api = vim.api

local F = require("user.functional")

local function is_lower(byte)
  return 97 <= byte and byte <= 122
end

local function delete_sign(bufnr, mark)
  local id = mark and mark:byte() * 100
  vim.fn.sign_unplace("MarkSigns", { buffer = bufnr, id = id })
end

local function add_sign(bufnr, mark, line)
  local sign_name = "Marks_" .. mark
  local id = mark:byte() * 100
  vim.fn.sign_define(sign_name, { text = mark, texthl = "MarkSignHL" })
  vim.fn.sign_place(id, "MarkSigns", sign_name, bufnr, { lnum = line, priority = 10 })
end

local function delete_mark(bufnr, mark)
  delete_sign(bufnr, mark)
  local extra = mark and " " .. mark or "!"
  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd("delmarks" .. extra)
  end)
end

local function register_mark(bufnr, mark, line)
  delete_mark(bufnr, mark)
  add_sign(bufnr, mark, line)
end

local function get_buf_marklist(bufnr)
  return api.nvim_buf_call(bufnr, function()
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

local function get_global_marklist()
  return F.concat(unpack(F.map(api.nvim_list_bufs(), function(bufnr)
    return get_buf_marklist(bufnr)
  end)))
end

local function mark_qf()
  local marklist = get_global_marklist()
  marklist = F.filter(marklist, function(mark_info)
    return api.nvim_buf_is_loaded(mark_info.bufnr)
  end)
  marklist = F.map(marklist, function(mark_info)
    local mark = mark_info.mark
    local bufnr = mark_info.bufnr
    local line = mark_info.pos[2]
    local text = api.nvim_buf_get_lines(bufnr, line - 1, line, true)[1]
    return { bufnr = bufnr, lnum = line, col = 0, text = " -- " .. mark .. " -- : " .. text }
  end)
  vim.fn.setqflist(marklist, " ")
  vim.fn.setqflist({}, "a", { title = "Marklist" })
  vim.api.nvim_command("botright copen")
end

local function get_next_mark(bufnr)
  local marks = get_buf_marklist(bufnr)
  marks = F.map(marks, function(mark_info)
    return mark_info.mark:byte()
  end)
  table.sort(marks, function(a, b)
    return a < b
  end)
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
  marks = F.filter(marks, function(mark_info)
    return mark_info.pos[2] == line
  end)
  marks = F.map(marks, function(mark_info)
    return mark_info.mark
  end)
  return marks
end

local function place_next_mark(bufnr, line)
  local next_mark = get_next_mark(bufnr)
  if next_mark ~= nil then
    register_mark(bufnr, next_mark, line)
    api.nvim_buf_set_mark(bufnr, next_mark, line, 0, {})
  end
end

local function toggle_mark()
  local bufnr = api.nvim_get_current_buf()
  local line = api.nvim_win_get_cursor(0)[1]

  local line_marks = get_line_marks(bufnr, line)
  if #line_marks ~= 0 then
    F.foreach(line_marks, function(mark)
      delete_mark(bufnr, mark)
    end)
  else
    if api.nvim_buf_get_option(bufnr, "buflisted") then
      place_next_mark(bufnr, line)
    end
  end
end

local function clear_all_marks()
  F.foreach(vim.api.nvim_list_bufs(), function(bufnr)
    if vim.api.nvim_buf_is_loaded(bufnr) then
      delete_mark(bufnr)
    end
  end)
end

vim.keymap.set({ "n" }, "dm", function()
  delete_mark(api.nvim_get_current_buf())
end)
vim.keymap.set({ "n", "x" }, "m", toggle_mark)
vim.keymap.set({ "n", "x" }, "M", mark_qf)
vim.keymap.set({ "n" }, "dam", clear_all_marks)

api.nvim_create_autocmd("BufUnload", {
  callback = function(args)
    delete_mark(args.buf)
  end,
})

-- local function update_signs(bufnr)
--   delete_sign(bufnr)
--   local marklist = get_buf_marklist(bufnr)
--   F.foreach(marklist, function(mark_info)
--     add_sign(bufnr, mark_info.mark, mark_info.pos[2])
--   end)
-- end

-- api.nvim_create_autocmd("BufRead", {
--   callback = function(args)
--     update_signs(args.buf)
--   end,
-- })
