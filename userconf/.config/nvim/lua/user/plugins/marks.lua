local F = require("user.functional")

local marks = require("marks")
marks.setup({
  default_mappings = true,
  cyclic = true,
  refresh_interval = 250,
  excluded_filetypes = {},
  mappings = {
    toggle = "mm",
  },
})

local function clear_all_marks()
  F.foreach(vim.api.nvim_list_bufs(), function(buf)
    if vim.api.nvim_buf_is_loaded(buf) then
      vim.api.nvim_buf_call(buf, marks.delete_buf)
    end
  end)
end

vim.keymap.set({ "n", "x" }, "M", "<ESC>:MarksListAll<CR>")
vim.keymap.set({ "n" }, "dam", clear_all_marks)
