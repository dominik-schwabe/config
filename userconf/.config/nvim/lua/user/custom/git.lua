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
  obj:_register_autocmds()
  local function get_diffstate()
    return obj
  end
  vim.w[obj.main_win].get_diffstate = get_diffstate
  vim.b[obj.main_buf].get_diffstate = get_diffstate
  vim.w[obj.dependent_win].get_diffstate = get_diffstate
  vim.b[obj.dependent_buf].get_diffstate = get_diffstate
  return obj
end

function Diffstate:_register_autocmds()
  if self.autocmds ~= nil then
    error("autocommands already registered")
  end
  local autocmd_ids = {}
  autocmd_ids[#autocmd_ids + 1] = vim.api.nvim_create_autocmd("BufWinEnter", {
    callback = function()
      if not self:is_consitent() then
        self:reset()
      end
    end,
  })
  local function reset_cb()
    vim.schedule(function()
      self:reset()
    end)
  end
  autocmd_ids[#autocmd_ids + 1] = vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(self.main_win),
    callback = reset_cb,
  })
  autocmd_ids[#autocmd_ids + 1] = vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(self.dependent_win),
    callback = reset_cb,
  })
  self.autocmd_ids = autocmd_ids
end

function Diffstate:_clear_autocmds()
  F.foreach(self.autocmd_ids, vim.api.nvim_del_autocmd)
end

function Diffstate:is_consitent()
  return vim.api.nvim_win_is_valid(self.main_win)
    and vim.api.nvim_win_is_valid(self.dependent_win)
    and vim.api.nvim_win_get_buf(self.main_win) == self.main_buf
    and vim.api.nvim_win_get_buf(self.dependent_win) == self.dependent_buf
end

function Diffstate:main_unchanged()
  return vim.api.nvim_win_is_valid(self.main_win) and vim.api.nvim_win_get_buf(self.main_win) == self.main_buf
end

function Diffstate:_close_untracked_wins()
  F.foreach(vim.api.nvim_list_wins(), function(win)
    if win ~= self.main_win and win ~= self.dependent_win then
      local win_buf = vim.api.nvim_win_get_buf(win)
      if
        win_buf == self.dependent_buf
        or (win_buf == self.main_buf and vim.wo[win].diff and vim.api.nvim_win_get_tabpage(win) == self.tabpage)
      then
        vim.api.nvim_win_close(win, true)
      end
    end
  end)
end

function Diffstate:reset()
  self:_clear_autocmds()
  self:_close_untracked_wins()
  reset_win(self.main_win)
  reset_win(self.dependent_win)
  reset_buf(self.main_buf)
  reset_buf(self.dependent_buf)
  if vim.api.nvim_win_is_valid(self.dependent_win) then
    if vim.api.nvim_win_get_buf(self.dependent_win) == self.dependent_buf then
      if #vim.api.nvim_tabpage_list_wins(self.tabpage) >= 2 then
        U.close_win(self.dependent_win)
      else
        vim.api.nvim_win_set_buf(self.dependent_win, self.main_buf)
      end
    elseif self:main_unchanged() then
      local dependent_buf = vim.api.nvim_win_get_buf(self.dependent_win)
      vim.api.nvim_win_set_buf(self.main_win, dependent_buf)
      U.close_win(self.dependent_win)
    end
  end
end

local function get_git_path(base_path)
  return vim.fs.find(".git", { path = base_path, upward = true, limit = math.huge })[1]
end

local function get_paths(buf)
  local file_path = vim.api.nvim_buf_get_name(buf)
  local paths = {}
  paths.file_path = U.exists(file_path) and file_path or nil
  paths.git_dir = paths.file_path and get_git_path(paths.file_path)
  paths.project_path = paths.git_dir and vim.fs.dirname(paths.git_dir)
  paths.rel_path = paths.project_path and paths.file_path:sub(#paths.project_path + 2)
  return paths
end

local function notify(msg, silent)
  if not silent then
    vim.notify(msg, vim.log.levels.ERROR)
  end
end

local function are_paths_invalid(paths, silent)
  if not paths.file_path then
    notify("invalid file", silent)
    return true
  elseif not paths.git_dir then
    notify("not in a git project", silent)
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

local function get_changed_files(git_dir, commit)
  return git_dir
    and git({ "--git-dir", git_dir, "--work-tree", vim.fs.dirname(git_dir), "diff", "--name-only", commit })
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

local function find_stats(opts)
  local tabpage = opts.tabpage or vim.api.nvim_win_get_tabpage(opts.win)
  local tab_windows = vim.api.nvim_tabpage_list_wins(tabpage)
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

local function reset_existing(opts)
  local old_stats = find_stats(opts)
  if old_stats ~= nil then
    old_stats:reset()
  end
  return old_stats
end

local function _diffsplit(main_win, opts)
  local old_stats = reset_existing({ win = main_win })
  if not vim.api.nvim_win_is_valid(main_win) then
    return
  end
  local main_buf = vim.api.nvim_win_get_buf(main_win)
  local paths = get_paths(main_buf)
  if are_paths_invalid(paths, old_stats ~= nil) then
    return
  end
  local commit_hash = opts.commit_hash or resolve_commit_hash(paths.git_dir, opts.commit)
  if not commit_hash then
    notify("could not reslove commit hash")
    return
  end
  if old_stats and old_stats.main_win == main_win and old_stats.commit == commit_hash then
    return
  end
  local lines = get_rel_lines(paths.project_path, commit_hash, paths.rel_path)
  if not lines then
    notify("no lines")
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

local function diffsplit(opts)
  local original_win = opts.win or vim.api.nvim_get_current_win()
  _diffsplit(original_win, opts)
end

local function cycle(direction)
  local old_stats = reset_existing({ tabpage = vim.api.nvim_get_current_tabpage() })
  local diff_opts = {}
  local prev_cycle_path
  if old_stats then
    diff_opts.commit_hash = old_stats.commit
    if vim.api.nvim_buf_is_valid(old_stats.main_buf) then
      prev_cycle_path = vim.api.nvim_buf_get_name(old_stats.main_buf)
    end
    if vim.api.nvim_win_is_valid(old_stats.main_win) then
      vim.api.nvim_set_current_win(old_stats.main_win)
    end
  else
    diff_opts.commit = "HEAD"
  end
  local git_dir = get_git_path(prev_cycle_path or vim.fn.getcwd())
  if not git_dir then
    notify("not in git project")
    return
  end
  local project_path = vim.fs.dirname(git_dir)
  project_path = project_path .. "/"
  local changed_files = F.filter(get_changed_files(git_dir, diff_opts.commit_hash or diff_opts.commit), function(path)
    return U.exists(project_path .. "/" .. path)
  end)
  local next_index = 1
  if #changed_files == 0 then
    notify("no changed files")
    return
  end
  if prev_cycle_path then
    prev_cycle_path = U.remove_path_prefix(prev_cycle_path, project_path)
    local found, index = F.sorted_find(changed_files, prev_cycle_path)
    if not found and direction > 0 then
      direction = direction - 1
    end
    next_index = math.fmod(index + direction, #changed_files)
    if next_index <= 0 then
      next_index = #changed_files + next_index
    end
  end
  local next_file = changed_files[next_index]
  vim.cmd("e " .. project_path .. "/" .. next_file)
  _diffsplit(vim.api.nvim_get_current_win(), diff_opts)
  vim.api.nvim_echo({ { string.format("%d/%d %s", next_index, #changed_files, next_file) } }, false, {})
end

vim.keymap.set("n", "<space>an", function()
  cycle(1)
end, { desc = "diff cycle next" })

vim.keymap.set("n", "<space>ap", function()
  cycle(-1)
end, { desc = "diff cycle previous" })

vim.keymap.set("n", "<space>gg", function()
  vim.ui.input({ default = "HEAD" }, function(commit)
    if commit ~= nil then
      diffsplit({ commit = commit })
    end
  end)
end, { desc = "select commit for diffsplit" })

vim.keymap.set("n", "<space>gd", function()
  diffsplit({ commit = "HEAD" })
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
    local original_buf = vim.api.nvim_win_get_buf(original_win)
    local paths = get_paths(original_buf)
    if are_paths_invalid(paths) then
      return
    end
    local refs = git({ "-C", paths.project_path, "--literal-pathspecs", "for-each-ref", "--format=%(refname:short)" })
    if not refs then
      notify("could not get refs")
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
          _diffsplit(original_win, { commit = action_state.get_selected_entry().value.commit })
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
