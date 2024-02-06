local F = require("rooter.functional")

local M = {}

function M.list_parents(path)
  local new_table = {}
  for v in vim.fs.parents(path) do
    new_table[#new_table + 1] = v
  end
  return new_table
end

function M.exists(path)
  return path and vim.fn.empty(vim.fn.glob(path)) == 0
end

function M.has_prefix(str, prefix)
  return str:sub(1, #prefix) == prefix
end

function M.has_suffix(str, suffix)
  return str:sub(-#suffix) == suffix
end

function M.remove_prefix(path, prefix)
  if M.has_prefix(path, prefix) then
    return prefix, path:sub(#prefix + 1)
  end
  return nil, path
end

function M.isdirectory(path)
  return path and vim.fn.isdirectory(path) == 1
end

function M.simplify_path(path)
  path = vim.fn.simplify(path)
  path = path:gsub("/+", "/")
  return path
end

function M.prepare_replacements(path_replacements)
  local paths = {}
  if type(path_replacements) == "function" then
    path_replacements = path_replacements()
  end
  F.foreach_items(path_replacements, function(path, replacement)
    path = vim.fs.normalize(path)
    path = M.simplify_path(path)
    paths[replacement] = path
  end)
  return paths
end

function M.add_slash(path)
  if path:sub(-1) ~= "/" then
    path = path .. "/"
  end
  return path
end

function M.replace_root_path(path, root, replacement)
  local home, rest_prefix = M.remove_prefix(path, M.add_slash(root))
  if home then
    path = replacement .. rest_prefix
  end
  return path
end

return M
