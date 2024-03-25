local U = require("rooter.utils")
local F = require("rooter.functional")
local C = require("rooter.constants")
local conf = require("rooter.config")

local M = {}
M.root_history = {}

local check_functions = {
  contains = function(dir, contents)
    return F.any(contents, function(content)
      return U.exists(U.path({ dir, content }))
    end)
  end,
  ends_with = function(dir, suffixes)
    return F.any(suffixes, function(suffix)
      return U.has_suffix(dir, suffix)
    end)
  end,
  patterns = function(dir, patterns)
    return F.any(patterns, function(pattern)
      return dir:match(pattern)
    end)
  end,
}

local keys = F.keys(check_functions)

local rooter_config = F.map(require("user.config").rooter, function(entry)
  return { entry[1] or 0, F.subset(entry, keys) }
end)

function M.find_root(base_path)
  if vim.fn.filereadable(base_path) == 1 then
    base_path = vim.fs.dirname(base_path)
  end
  local dirs = U.list_parents(base_path .. "/")
  for i, dir in ipairs(dirs) do
    for _, config_entry in ipairs(rooter_config) do
      local level, entry = unpack(config_entry)
      local context_dir = dirs[i + level]
      if
        context_dir
        and U.isdirectory(context_dir)
        and F.any(keys, function(key)
          return entry[key] and check_functions[key](context_dir, entry[key])
        end)
      then
        return U.path({ dir }, { is_dir = true }), base_path
      end
    end
  end
  return nil, base_path
end

local function set_root(root, opts)
  opts = vim.F.if_nil(opts, {})
  local is_fallback = vim.F.if_nil(opts.is_fallback, false)
  if U.isdirectory(root) then
    M.root_history[root] = { timestamp = vim.loop.now(), is_fallback = is_fallback }
    if root ~= vim.fn.getcwd() then
      vim.api.nvim_set_current_dir(root)
    end
  end
end

function M.trigger(opts)
  if F.contains(C.NOPATH_BUFTYPES, vim.bo[opts.buf].buftype) then
    return
  end
  local base_path = U.path({ opts.file })
  if base_path:sub(0, 1) ~= "/" then
    return
  end
  local found_root, fallback = M.find_root(base_path)
  local root = found_root or fallback
  local is_fallback = found_root == nil
  set_root(root, { is_fallback = is_fallback })
end

function M.pick_root(opts)
  opts = vim.F.if_nil(opts, {})
  local include_fallbacks = vim.F.if_nil(opts.include_fallbacks, false)
  local callback = opts.callback
  local history = F.entries(M.root_history)
  if include_fallbacks then
    history = F.filter(history, function(e)
      return not e[2].is_fallback
    end)
  end
  if #history == 0 then
    vim.notify("not root history to pick", vim.log.levels.ERROR)
    return
  end
  table.sort(history, function(a, b)
    a, b = a[2], b[2]
    return a.timestamp > b.timestamp
  end)
  history = F.map(history, function(e)
    return e[1]
  end)
  local replacements = U.prepare_replacements(conf.config.path_replacements)
  vim.ui.select(history, {
    prompt = "Select cwd:",
    format_item = function(path)
      local replaced = F.map(F.entries(replacements), function(item)
        local root, replacement = unpack(item)
        local split_root, rest_prefix = U.remove_prefix(path, U.path({ root }, { is_dir = true }))
        if split_root then
          return { #split_root, replacement .. rest_prefix }
        end
      end)
      replaced = F.filter(replaced, function(e)
        return e ~= nil
      end)
      replaced[#replaced + 1] = { 0, path }
      table.sort(replaced, function(a, b)
        return a[1] > b[1]
      end)
      return replaced[1][2]
    end,
  }, function(root)
    if root then
      set_root(root, { is_fallback = M.root_history[root].is_fallback })
      if callback then
        callback(root)
      end
    end
  end)
end

function M.setup(opts)
  conf.setup(opts)

  if conf.config.auto_chdir then
    vim.opt.autochdir = false
  end

  if conf.config.setup_auto_cmd then
    local augroup = vim.api.nvim_create_augroup("Rooter", {})
    vim.api.nvim_create_autocmd({ "BufEnter" }, {
      group = augroup,
      callback = M.trigger,
    })
  end
end

return M
