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
