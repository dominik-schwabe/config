local F = require("user.functional")
local U = require("user.utils")

local Job = require("plenary.job")

local M = {}

local function diff_on(win)
  vim.api.nvim_win_call(win, function()
    vim.cmd("diffthis")
    vim.wo.foldenable = true
  end)
end

local function diff_off(win)
  vim.api.nvim_win_call(win, function()
    vim.cmd("diffoff!")
  end)
end

local function reset_win(win)
  if vim.api.nvim_win_is_valid(win) then
    diff_off(win)
    vim.w[win].get_diffstate = nil
  end
end

local function reset_buf(buf)
  if vim.api.nvim_buf_is_valid(buf) then
    vim.b[buf].get_diffstate = nil
  end
end

local Diffstate = {}
Diffstate.__index = Diffstate

function Diffstate:new(obj)
  obj = setmetatable(obj, self)
  local autocmd_ids = {}
  autocmd_ids[#autocmd_ids + 1] = vim.api.nvim_create_autocmd("BufWinEnter", {
    callback = function()
      if not obj:is_consitent() then
        obj:reset(true)
      end
    end,
  })
  local function reset_cb()
    obj:reset()
  end
  autocmd_ids[#autocmd_ids + 1] = vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(obj.main_win),
    callback = reset_cb,
  })
  autocmd_ids[#autocmd_ids + 1] = vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(obj.dependent_win),
    callback = reset_cb,
  })
  obj.autocmd_ids = autocmd_ids
  local function get_diffstate()
    return obj
  end
  vim.w[obj.main_win].get_diffstate = get_diffstate
  vim.b[obj.main_buf].get_diffstate = get_diffstate
  vim.w[obj.dependent_win].get_diffstate = get_diffstate
  vim.b[obj.dependent_buf].get_diffstate = get_diffstate
  return obj
end

function Diffstate:is_consitent()
  return vim.api.nvim_win_is_valid(self.main_win)
    and vim.api.nvim_win_is_valid(self.dependent_win)
    and vim.api.nvim_win_get_buf(self.main_win) == self.main_buf
    and vim.api.nvim_win_get_buf(self.dependent_win) == self.dependent_buf
end

function Diffstate:reset(dont_set_buf)
  F.foreach(self.autocmd_ids, vim.api.nvim_del_autocmd)
  reset_win(self.main_win)
  reset_win(self.dependent_win)
  reset_buf(self.main_buf)
  reset_buf(self.dependent_buf)
  if
    vim.api.nvim_win_is_valid(self.dependent_win)
    and vim.api.nvim_win_get_buf(self.dependent_win) == self.dependent_buf
  then
    local current_win = vim.api.nvim_get_current_win()
    local get_current_diffstate = vim.w[current_win].get_diffstate
    local should_close = get_current_diffstate == nil
      or get_current_diffstate().dependent_win == current_win
      or #vim.api.nvim_tabpage_list_wins(self.tabpage) > 2
    if should_close then
      U.close_win(self.dependent_win)
    else
      if not dont_set_buf then
        vim.api.nvim_win_set_buf(self.dependent_win, self.main_buf)
      end
    end
  end
end

local function get_paths(win)
  local buf = vim.api.nvim_win_get_buf(win)
  local file_path = vim.api.nvim_buf_get_name(buf)
  local paths = {}
  paths.file_path = U.exists(file_path) and file_path or nil
  paths.git_dir = paths.file_path
    and vim.fs.find(".git", { path = paths.file_path, upward = true, limit = math.huge })[1]
  paths.project_path = paths.git_dir and vim.fs.dirname(paths.git_dir)
  paths.rel_path = paths.project_path and paths.file_path:sub(#paths.project_path + 2)
  return paths
end

local function bail_paths(paths)
  if not paths.file_path then
    vim.notify("invalid file", vim.log.levels.ERROR)
    return true
  elseif not paths.git_dir then
    vim.notify("not in a git project", vim.log.levels.ERROR)
    return true
  end
  return false
end

local function git(args)
  local job = Job:new({
    command = "git",
    args = args,
    enable_recordings = true,
  })
  local results = job:sync()
  return job.code == 0 and results or nil
end

local function commits(paths)
  local entries =
    git({ "-C", paths.project_path, "--literal-pathspecs", "log", "--pretty=%h (%ar %an) %s", paths.file_path })
  return F.map(entries, function(text)
    local commit, message = text:gmatch("(%w+) (.*)")()
    return {
      commit = commit,
      message = message,
      text = text,
    }
  end)
end

local function find_stats(main_win)
  local tab_windows = vim.api.nvim_tabpage_list_wins(vim.api.nvim_win_get_tabpage(main_win))
  local window_with_stats = F.find(tab_windows, function(win)
    return vim.w[win].get_diffstate ~= nil
  end)
  return window_with_stats and vim.w[window_with_stats].get_diffstate()
end

local function resolve_commit_hash(git_dir, commit)
  local commit_hash = git({ "--git-dir", git_dir, "--literal-pathspecs", "rev-parse", "--verify", commit, "--" })
  return commit_hash and commit_hash[1]
end

local function get_rel_lines(project_path, commit_hash, rel_path)
  return git({ "-C", project_path, "--literal-pathspecs", "show", commit_hash .. ":" .. rel_path })
end

local function reset_dependent(main_win)
  local old_stats = vim.w[main_win].get_diffstate
  if old_stats ~= nil and old_stats().dependent_win == main_win then
    old_stats():reset()
    return true
  end
  return false
end

local function reset_same_existing(main_win, commit_hash)
  local old_stats = find_stats(main_win)
  if old_stats ~= nil then
    old_stats:reset()
    if old_stats.main_win == main_win and old_stats.commit == commit_hash then
      return true
    end
  end
  return false
end

local function _diffsplit(main_win, commit)
  if reset_dependent(main_win) then
    return
  end
  local main_buf = vim.api.nvim_win_get_buf(main_win)
  local paths = get_paths(main_win)
  if bail_paths(paths) then
    return
  end
  local commit_hash = resolve_commit_hash(paths.git_dir, commit)
  if not commit_hash then
    vim.notify("git command not successful", vim.log.levels.ERROR)
    return
  end
  if reset_same_existing(main_win, commit_hash) then
    return
  end
  local lines = get_rel_lines(paths.project_path, commit_hash, paths.rel_path)
  if not lines then
    vim.notify("no lines", vim.log.levels.ERROR)
    return
  end
  local dependent_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(dependent_buf, 0, 1, true, lines)
  local original_line, _ = unpack(vim.api.nvim_win_get_cursor(main_win))
  vim.cmd("vsplit")
  local dependent_win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(main_win)
  vim.bo[dependent_buf].filetype = vim.bo[main_buf].filetype
  vim.bo[dependent_buf].modifiable = false
  vim.bo[dependent_buf].swapfile = false
  vim.bo[dependent_buf].bufhidden = "wipe"
  vim.api.nvim_win_set_buf(dependent_win, dependent_buf)
  vim.keymap.set("n", "q", "<CMD>quit<CR>", { buffer = dependent_buf, desc = "close the diffsplit buffer" })
  diff_on(main_win)
  diff_on(dependent_win)
  Diffstate:new({
    tabpage = vim.api.nvim_win_get_tabpage(main_win),
    main_win = main_win,
    main_buf = main_buf,
    dependent_win = dependent_win,
    dependent_buf = dependent_buf,
    commit = commit_hash,
  })
  vim.api.nvim_win_set_cursor(main_win, { original_line, 0 })
  vim.cmd.normal("h") -- this is for syncing the cursors
  vim.api.nvim_set_current_win(dependent_win)
end

local function diffsplit(commit, win)
  local original_win = win or vim.api.nvim_get_current_win()
  _diffsplit(original_win, commit)
end

vim.keymap.set("n", "<space>gg", function()
  vim.ui.input({ default = "HEAD" }, function(commit)
    if commit ~= nil then
      diffsplit(commit)
    end
  end)
end, { desc = "select commit for diffsplit" })

vim.keymap.set("n", "<space>gd", function()
  diffsplit("HEAD")
end, { desc = "open diffsplit on HEAD commit" })

function M.make_telescope_extension()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local entry_display = require("telescope.pickers.entry_display")
  local conf = require("telescope.config").values

  local function gen_from_history(opts)
    local displayer = entry_display.create({
      separator = " ",
      items = {
        { width = #tostring(opts.history_length) },
        { remaining = true },
      },
    })

    local make_display = function(entry)
      return displayer({
        { entry.value.index, "TelescopeResultsNumber" },
        entry.value.text,
      })
    end

    return function(entry)
      return {
        value = entry,
        ordinal = entry.text,
        content = entry.text,
        display = make_display,
      }
    end
  end

  local function entry_point(opts)
    opts = opts or {}
    local original_win = vim.api.nvim_get_current_win()
    local paths = get_paths(original_win)
    if bail_paths(paths) then
      return
    end
    local refs = git({ "-C", paths.project_path, "--literal-pathspecs", "for-each-ref", "--format=%(refname:short)" })
    if not refs then
      vim.notify("git command not successful")
      return
    end
    local filtered_commits = F.filter({ "HEAD", "FETCH_HEAD", "ORIG_HEAD", "MERGE_HEAD" }, function(commit)
      return U.exists(vim.fs.normalize(paths.git_dir .. "/" .. commit))
    end)
    local named = F.map(F.concat(filtered_commits, refs), function(commit)
      return {
        commit = commit,
        message = commit,
        text = commit,
      }
    end)
    local results = F.concat(commits(paths), named)
    for index, entry in ipairs(results) do
      entry.index = index
    end
    opts.history_length = #results

    local function attach_mappings(_, map)
      local function accept(bufnr)
        actions.close(bufnr)
        vim.schedule(function()
          _diffsplit(original_win, action_state.get_selected_entry().value.commit)
        end)
      end
      map("i", "<CR>", accept)
      map("n", "<CR>", accept)
      return true
    end

    pickers
      .new(opts, {
        prompt_title = "Commits",
        finder = finders.new_table({
          results = results,
          entry_maker = gen_from_history(opts),
        }),
        attach_mappings = attach_mappings,
        sorter = conf.generic_sorter(opts),
      })
      :find()
  end
  return require("telescope").register_extension({
    exports = {
      diffsplit = entry_point,
    },
  })
end

return M
