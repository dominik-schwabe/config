local F = require("repl.functional")

local marks = require("marks")
marks.setup({
  default_mappings = true,
  cyclic = true,
  refresh_interval = 250,
  excluded_filetypes = {},
  mappings = {
    set_next = "mm",
  },
})

local function clear_all_marks()
  F.foreach(vim.api.nvim_list_bufs(), function(buf)
    if vim.api.nvim_buf_is_loaded(buf) then
      -- vim.api.nvim_buf_call(buf, function() vim.cmd("delmarks!") end)
      vim.api.nvim_buf_call(buf, marks.delete_buf)
    end
  end)
end

vim.keymap.set({ "n", "x" }, "M", "<CMD>:MarksQFListAll<CR>")
-- vim.keymap.set({ "n", "x" }, "dm<space>", "<CMD>bufdo delmarks!<CR>")
vim.keymap.set({ "n", "x" }, "dam", clear_all_marks)
