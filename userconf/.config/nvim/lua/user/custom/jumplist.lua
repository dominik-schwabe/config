local F = require("user.functional")

local function set_jumplist()
  local jumplist = vim.fn.getjumplist()[1]

  local filtered_jumplist = F.reverse(F.map(jumplist, function(e)
    if vim.api.nvim_buf_is_loaded(e.bufnr) then
      return {
        bufnr = e.bufnr,
        filename = e.filename or vim.api.nvim_buf_get_name(e.bufnr),
        lnum = vim.F.if_nil(e.lnum, 1),
        col = vim.F.if_nil(e.col, 1),
        text = vim.api.nvim_buf_get_lines(e.bufnr, e.lnum, e.lnum + 1, false)[1] or "",
      }
    end
  end))

  vim.fn.setqflist(filtered_jumplist, " ")
  vim.fn.setqflist({}, "a", { title = "Jumplist" })
  vim.api.nvim_command("botright copen")
end

vim.keymap.set({ "n", "x" }, "<space>j", set_jumplist, { desc = "open the quickfix with the jumplist" })

local backward_key = vim.api.nvim_replace_termcodes("<c-o>", true, false, true)
local forward_key = vim.api.nvim_replace_termcodes("<c-i>", true, false, true)

local function is_valid(bufnr)
  return bufnr ~= nil and vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr)
end

local function jump(direction, opt)
  opt = opt or {}
  local once_per_buffer = opt.once_per_buffer
  local jumplist, start_pos = unpack(vim.fn.getjumplist())
  if #jumplist == 0 then
    return
  end
  start_pos = start_pos + 1

  local start_bufnr = vim.api.nvim_get_current_buf()

  local max_lookback = math.min(#jumplist, 100)

  local current_pos = start_pos + direction
  while 1 <= current_pos and current_pos <= max_lookback do
    local current_bufnr = jumplist[current_pos].bufnr
    if is_valid(current_bufnr) and (not once_per_buffer or start_bufnr ~= current_bufnr) then
      local displacement = current_pos - start_pos
      if displacement < 0 then
        vim.api.nvim_feedkeys(-displacement .. backward_key, "n", false)
      elseif displacement > 0 then
        vim.api.nvim_feedkeys(displacement .. forward_key, "n", false)
      end
      return
    end
    current_pos = current_pos + direction
  end
end

vim.keymap.set({ "n" }, "<C-i>", F.f(jump, 1), { desc = "jump to next jumpmark" })
vim.keymap.set({ "n" }, "<C-o>", F.f(jump, -1), { desc = "jump to previous jumpmark" })
vim.keymap.set({ "n" }, "<space>i", F.f(jump, 1, { once_per_buffer = true, desc = "jump to next file" }))
vim.keymap.set({ "n" }, "<space>o", F.f(jump, -1, { once_per_buffer = true, desc = "jump to previous file" }))
