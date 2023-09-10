local pickers = require("telescope.pickers")
local entry_display = require("telescope.pickers.entry_display")
local action_state = require("telescope.actions.state")
local make_entry = require("telescope.make_entry")
local actions = require("telescope.actions")
local finders = require("telescope.finders")
local Path = require("plenary.path")
local utils = require("telescope.utils")
local conf = require("telescope.config").values

local F = require("user.functional")
local U = require("user.utils")

local function stopinsert()
  vim.cmd("stopinsert")
end

local function delete_buffer(prompt_bufnr)
  local current_picker = action_state.get_current_picker(prompt_bufnr)
  current_picker:delete_selection(function(selection)
    local info = vim.fn.getbufinfo(selection.bufnr)[1]
    if info.changed == 1 then
      vim.notify("can not delete buffer with unsaved changes", vim.log.levels.WARN)
      return false
    end
    local windows = F.filter(vim.api.nvim_list_wins(), function(win)
      return not U.is_floating(win)
    end)
    local close_wins = F.filter(windows, function(win)
      return vim.api.nvim_win_get_buf(win) == selection.bufnr
    end)
    if #close_wins >= #windows then
      local keep_win = close_wins[1]
      close_wins = F.slice(close_wins, 2)
      local left_buffers = F.filter(U.list_buffers({ mru = true }), function(buf)
        return buf ~= selection.bufnr
      end)
      if #left_buffers > 0 then
        vim.api.nvim_win_set_buf(keep_win, left_buffers[1])
      else
        local dummy_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_win_set_buf(keep_win, dummy_buf)
        actions.close(prompt_bufnr)
      end
    end
    F.foreach(close_wins, function(win)
      vim.api.nvim_win_close(win, false)
    end)
    local force = vim.api.nvim_buf_get_option(selection.bufnr, "buftype") == "terminal"
    local ok = pcall(vim.api.nvim_buf_delete, selection.bufnr, { force = force })
    return ok
  end)
end

local function attach_mappings(_, map)
  map({ "i", "n" }, "<F2>", actions.close)
  map("i", "<ESC>", stopinsert)
  map("i", "<C-d>", delete_buffer, { nowait = true })
  map("i", "<C-S>", actions.file_vsplit, { nowait = true })
  map("i", "<C-V>", actions.file_split, { nowait = true })
  map("n", "d", delete_buffer, { nowait = true })
  map("n", "s", actions.file_vsplit, { nowait = true })
  map("n", "v", actions.file_split, { nowait = true })
  return true
end

local function gen_from_buffer(opts)
  opts = opts or {}

  local icon_width = 2

  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = opts.bufnr_width },
      { width = 4 },
      { width = icon_width },
      { width = opts.longest_tail, remaining = true },
      { remaining = true },
    },
  })

  local cwd = vim.fn.expand(opts.cwd or vim.loop.cwd())

  local make_display = function(entry)
    opts.__prefix = opts.bufnr_width + 4 + icon_width + 3 + 1
    local icon, hl_group = utils.get_devicons(entry.is_path and entry.filename or "terminal")

    return displayer({
      { entry.bufnr, "TelescopeResultsNumber" },
      { entry.indicator, "TelescopeResultsComment" },
      { icon, hl_group },
      { entry.tail, entry.is_path and "Olive" or "Purple" },
      { entry.filename, "Grey" },
    })
  end

  return function(entry)
    local bufname = entry.info.name ~= "" and entry.info.name or "[No Name]"
    bufname = Path:new(bufname):normalize(cwd)

    local hidden = entry.info.hidden == 1 and "h" or "a"
    local readonly = vim.api.nvim_buf_get_option(entry.bufnr, "readonly") and "=" or " "
    local changed = entry.info.changed == 1 and "+" or " "
    local indicator = hidden .. readonly .. changed

    return make_entry.set_default_entry_mt({
      value = bufname,
      ordinal = entry.bufnr .. " : " .. entry.tail .. bufname,
      display = make_display,
      is_path = entry.is_path,
      bufnr = entry.bufnr,
      filename = bufname,
      tail = entry.tail,
      indicator = indicator,
    }, opts)
  end
end

local entry_point = function(opts)
  local path_bufnrs = U.list_buffers({ mru = true, buftype = { "", "acwrite" } })
  local terminal_bufnrs = F.reverse(U.list_buffers({ mru = true, unlisted = true, buftype = "terminal" }))
  local all_bufnrs = F.concat(terminal_bufnrs, path_bufnrs)

  local buffers = F.map(all_bufnrs, function(bufnr)
    local info = vim.fn.getbufinfo(bufnr)[1]
    local tail = utils.path_tail(info.name)
    return {
      bufnr = bufnr,
      is_path = vim.bo[bufnr].buftype ~= "terminal",
      tail = tail,
      info = info,
    }
  end)

  opts.longest_tail = F.max(F.map(buffers, function(entry)
    return #entry.tail
  end) or 0)
  opts.bufnr_width = #tostring(F.max(all_bufnrs) or 0)

  local default_selection_idx = #terminal_bufnrs + 1

  pickers
    .new(opts, {
      prompt_title = "Buffers",
      finder = finders.new_table({
        results = buffers,
        entry_maker = gen_from_buffer(opts),
      }),
      attach_mappings = attach_mappings,
      sorter = conf.generic_sorter(opts),
      default_selection_index = default_selection_idx,
      initial_mode = "normal",
    })
    :find()
end

return require("telescope").register_extension({
  exports = {
    ["custom_buffers"] = entry_point,
  },
})
