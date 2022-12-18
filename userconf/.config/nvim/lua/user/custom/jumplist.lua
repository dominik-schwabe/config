local F = require("user.functional")

local function set_jumplist()
  local jumplist = vim.fn.getjumplist()[1]

  local filtered_jumplist = F.reverse(F.map(jumplist, function(e)
    if vim.api.nvim_buf_is_valid(e.bufnr) then
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

vim.keymap.set({ "n", "x" }, "Ä", set_jumplist)

local backward_key = vim.api.nvim_replace_termcodes("<c-o>", true, false, true)
local forward_key = vim.api.nvim_replace_termcodes("<c-i>", true, false, true)

local function is_valid(bufnr)
  return bufnr ~= nil and vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr)
end

local function jump(direction)
  local jumplist_tuple = vim.fn.getjumplist()

  local vim_jumplist = jumplist_tuple[1]
  local start_pos = jumplist_tuple[2] + 1

  local max_lookback = math.min(#vim_jumplist, 100)

  local current_pos = start_pos + direction
  while 1 <= current_pos and current_pos <= max_lookback do
    if is_valid(vim_jumplist[current_pos].bufnr) then
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

vim.keymap.set({ "n" }, "<C-i>", F.f(jump, 1))
vim.keymap.set({ "n" }, "<C-o>", F.f(jump, -1))
