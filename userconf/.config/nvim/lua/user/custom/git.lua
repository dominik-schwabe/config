local F = require("user.functional")
local U = require("user.utils")

local Job = require("plenary.job")

local M = {}

local function diff_on(win)
  vim.api.nvim_win_call(win, function()
    vim.cmd("diffthis")
  end)
end

local function diff_off(bufnr)
  vim.api.nvim_buf_call(bufnr, function()
    if vim.api.nvim_buf_is_loaded(bufnr) then
      vim.cmd("diffoff")
    end
  end)
end

local function get_paths(bufnr)
  local file_path = vim.api.nvim_buf_get_name(bufnr)
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
    vim.notify("invalid file")
    return true
  elseif not paths.git_dir then
    vim.notify("not in a git project")
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

local function _diffsplit(original_bufnr, commit)
  local paths = get_paths(original_bufnr)
  if bail_paths(paths) then
    return
  end
  local commit_hash = git({ "--git-dir", paths.git_dir, "--literal-pathspecs", "rev-parse", "--verify", commit, "--" })
  if not commit_hash then
    vim.notify("git command not successful")
    return
  end
  commit_hash = commit_hash[1]
  local lines = git({ "-C", paths.project_path, "--literal-pathspecs", "show", commit_hash .. ":" .. paths.rel_path })
  if not lines then
    vim.notify("no lines")
    return
  end
  local original_win = vim.api.nvim_get_current_win()
  local diff_bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(diff_bufnr, 0, 1, true, lines)
  local original_line, _ = unpack(vim.api.nvim_win_get_cursor(original_win))
  vim.cmd("vsplit")
  local diff_win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(original_win)
  vim.bo[diff_bufnr].filetype = vim.bo[original_bufnr].filetype
  vim.bo[diff_bufnr].modifiable = false
  vim.bo[diff_bufnr].swapfile = false
  vim.bo[diff_bufnr].bufhidden = "wipe"
  vim.api.nvim_win_set_buf(diff_win, diff_bufnr)
  vim.keymap.set("n", "q", "<CMD>quit<CR>", { buffer = diff_bufnr, desc = "close the diffsplit buffer" })
  diff_on(original_win)
  diff_on(diff_win)
  vim.api.nvim_win_set_option(original_win, "foldenable", true)
  vim.api.nvim_win_set_option(diff_win, "foldenable", true)
  local reseted = false
  local function reset_diff()
    if not reseted then
      diff_off(original_bufnr)
      diff_off(diff_bufnr)
      U.close_win(diff_win)
      reseted = true
    end
  end
  vim.api.nvim_win_set_cursor(original_win, { original_line, 0 })
  vim.cmd.normal("h") -- this is for syncing the cursors
  vim.api.nvim_set_current_win(diff_win)
  vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
    buffer = original_bufnr,
    callback = reset_diff,
    once = true,
  })
  vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
    buffer = diff_bufnr,
    callback = reset_diff,
    once = true,
  })
  vim.api.nvim_create_autocmd({ "WinNew", "WinClosed", "BufWinEnter" }, {
    callback = reset_diff,
    once = true,
  })
end

local function diffsplit(commit)
  local original_bufnr = U.mru_buffers()[1]
  _diffsplit(original_bufnr, commit)
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
    local original_bufnr = U.mru_buffers()[1]
    local paths = get_paths(original_bufnr)
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
          _diffsplit(original_bufnr, action_state.get_selected_entry().value.commit)
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
