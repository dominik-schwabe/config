local F = require("user.functional")
local U = require("user.utils")

local function set_jumplist()
  local jumplist = vim.fn.getjumplist()[1]
  local filtered_jumplist = F.reverse(F.filter_map(jumplist, function(e)
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
  U.quickfix(filtered_jumplist, "Jumplist")
end

vim.keymap.set({ "n", "x" }, "<leader>oj", set_jumplist, { desc = "open the quickfix with the jumplist" })

local function jump(direction, opt)
  opt = opt or {}
  local buffer = opt.buffer
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
    if
      current_bufnr ~= nil
      and vim.api.nvim_buf_is_loaded(current_bufnr)
      and (not buffer or start_bufnr ~= current_bufnr)
    then
      local displacement = current_pos - start_pos
      if displacement < 0 then
        return -displacement .. "<c-o>"
      elseif displacement > 0 then
        return displacement .. "<c-i>"
      end
      return
    end
    current_pos = current_pos + direction
  end
end

local jump_cb = F.f(jump)

vim.keymap.set("n", "<C-i>", jump_cb(1), { expr = true, desc = "jump to next jumpmark" })
vim.keymap.set("n", "<C-o>", jump_cb(-1), { expr = true, desc = "jump to previous jumpmark" })
vim.keymap.set("n", "<leader>i", jump_cb(1), { expr = true, desc = "jump to next file buffer" })
vim.keymap.set("n", "<leader>o", jump_cb(-1), { expr = true, desc = "jump to previous file buffer" })
