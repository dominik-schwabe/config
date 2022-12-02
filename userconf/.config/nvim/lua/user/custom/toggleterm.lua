local cmd = vim.cmd
local api = vim.api
local fn = vim.fn

local term_buf
local term_win
local function open_term(height, bottom)
  if bottom then
    cmd("botright new")
    api.nvim_win_set_height(0, height)
  else
    cmd("vertical botright new")
  end
  term_win = api.nvim_get_current_win()
  if term_buf ~= nil and api.nvim_buf_is_loaded(term_buf) then
    api.nvim_win_set_buf(term_win, term_buf)
  else
    fn.termopen(os.getenv("SHELL"), { detach = 0 })
    term_buf = fn.bufnr("")
    cmd("startinsert")
  end
  api.nvim_buf_set_name(term_buf, "term://toggleterm")
  api.nvim_buf_set_option(term_buf, "buflisted", false)
  api.nvim_win_set_option(term_win, "spell", false)
  api.nvim_win_set_option(term_win, "number", false)
  api.nvim_win_set_option(term_win, "relativenumber", false)
  api.nvim_win_set_option(term_win, "signcolumn", "no")
end

local function toggle_term(height, bottom)
  if fn.win_gotoid(term_win) ~= 0 then
    local this_window = fn.winnr()
    local is_bottom = (this_window == fn.winnr("h"))
      and (this_window == fn.winnr("l"))
      and (this_window == fn.winnr("j"))
    cmd("hide")
    if is_bottom ~= bottom then
      open_term(height, bottom)
    end
  else
    open_term(height, bottom)
  end
end

local function toggle_term_bottom()
  toggle_term(10, true)
end

local function toggle_term_right()
  toggle_term(10, false)
end

vim.api.nvim_create_user_command("ToggleTermBottom", toggle_term_bottom, {})
vim.api.nvim_create_user_command("ToggleTermRight", toggle_term_right, {})

vim.keymap.set({ "n", "x", "t" }, "<F10>", toggle_term_bottom)
vim.keymap.set("i", "<F10>", toggle_term_bottom)
vim.keymap.set({ "n", "x", "t" }, "<F22>", toggle_term_right)
vim.keymap.set("i", "<F22>", toggle_term_right)

vim.api.nvim_create_autocmd("TermClose", {
  pattern = { "term://toggleterm" },
  callback = function(args)
    api.nvim_buf_delete(args.buf, { force = true })
  end,
})
