local U = require("user.utils")
local F = require("user.functional")
local C = require("user.constants")

vim.opt.autochdir = false

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
  local dirs = list_parents(base_path .. "/")
  for i, dir in ipairs(dirs) do
    for _, config_entry in ipairs(rooter_config) do
      local level, entry = unpack(config_entry)
      local context_dir = dirs[i + level]
      if
        context_dir
        and F.any(keys, function(key)
          return entry[key] and check_functions[key](context_dir, entry[key])
        end)
      then
        return dir
      end
    end
  end
  return nil
end

local function chdir(args)
  if F.contains(C.NOPATH_BUFTYPES, vim.bo[args.buf].buftype) then
    return
  end
  local base_path = vim.fn.expand("%:p:h", true)
  base_path = vim.fs.normalize(base_path)
  base_path = U.simplify_path(base_path)
  if base_path:sub(0, 1) ~= "/" then
    return
  end
  local root = find_root(base_path) or base_path
  if root ~= vim.fn.getcwd() and U.exists(root) then
    vim.api.nvim_set_current_dir(root)
  end
end

vim.api.nvim_create_augroup("UserRooter", {})
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  group = "UserRooter",
  callback = chdir,
})
