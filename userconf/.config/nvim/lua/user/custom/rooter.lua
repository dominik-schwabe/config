local U = require("user.utils")
local F = require("user.functional")
local C = require("user.constants")

vim.opt.autochdir = false

local root_history = {}

local check_functions = {
  contains = function(dir, contents)
    return F.any(contents, function(content)
      return U.exists(dir .. "/" .. content)
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

local function list_parents(path)
  local new_table = {}
  for v in vim.fs.parents(path) do
    new_table[#new_table + 1] = v
  end
  return new_table
end

local function find_root(base_path)
  if vim.fn.filereadable(base_path) == 1 then
    base_path = vim.fs.dirname(base_path)
  end
  local dirs = list_parents(base_path .. "/")
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
        return dir, base_path
      end
    end
  end
  return nil, base_path
end

local function set_root(root, opts)
  opts = vim.F.if_nil(opts, {})
  local is_fallback = vim.F.if_nil(opts.is_fallback, false)
  if U.isdirectory(root) then
    root_history[root] = { timestamp = vim.loop.now(), is_fallback = is_fallback }
    if root ~= vim.fn.getcwd() then
      vim.api.nvim_set_current_dir(root)
    end
  end
end

local function chdir(args)
  if F.contains(C.NOPATH_BUFTYPES, vim.bo[args.buf].buftype) then
    return
  end
  local base_path = args.file
  base_path = vim.fs.normalize(base_path)
  base_path = U.simplify_path(base_path)
  if base_path:sub(0, 1) ~= "/" then
    return
  end
  local found_root, fallback = find_root(base_path)
  local root = found_root or fallback
  local is_fallback = found_root == nil
  set_root(root, { is_fallback = is_fallback })
end

local function pick_root(opts)
  opts = vim.F.if_nil(opts, {})
  local no_fallback = vim.F.if_nil(opts.no_fallback, true)
  local history = F.entries(root_history)
  if no_fallback then
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
  local replacements = U.path_replacements()
  vim.ui.select(history, {
    prompt = "Select cwd:",
    format_item = function(path)
      local replaced = path
      for replacement, root in pairs(replacements) do
        replaced = U.replace_root_path(replaced, root, replacement)
        if replaced ~= path then
          return replaced
        end
      end
      return replaced
    end,
  }, function(root)
    if root then
      set_root(root, { is_fallback = root_history[root].is_fallback })
      F.load("nvim-tree.api", function(tree_api)
        tree_api.tree.open({ path = root })
      end)
    end
  end)
end

vim.keymap.set("n", "<space>cc", pick_root, { desc = "pick a root" })

vim.api.nvim_create_augroup("UserRooter", {})
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  group = "UserRooter",
  callback = chdir,
})
