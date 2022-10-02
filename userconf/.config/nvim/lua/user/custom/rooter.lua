local utils = require("user.utils")

vim.opt.autochdir = false

local base = {
  has = {},
  ends_with = {},
  parent_ends_with = {},
  patterns = {},
}
local rooter_config = vim.tbl_deep_extend("force", base, require("user.config").rooter)

local function list_parents(path)
  local new_table = {}
  for v in vim.fs.parents(path) do
    new_table[#new_table + 1] = v
  end
  return new_table
end

local function has(dir, content)
  for _, c in ipairs(content) do
    if utils.exists(dir .. "/" .. c) then
      return true
    end
  end
  return false
end

local function ends_with(dir, suffixes)
  for _, suffix in ipairs(suffixes) do
    if dir:sub(-string.len(suffix)) == suffix then
      return true
    end
  end
  return false
end

local function parent_ends_with(dir, suffixes)
  return ends_with(vim.fs.dirname(dir), suffixes)
end

local function find_root(base_path)
  if not utils.exists(base_path) then
    return
  end
  local dirs = list_parents(base_path .. "/")
  for i, dir in ipairs(dirs) do
    if
      has(dir, rooter_config["has"])
      or ends_with(dir, rooter_config["ends_with"])
      or parent_ends_with(dir, rooter_config["parent_ends_with"])
    then
      return dir
    end
    for _, p in ipairs(rooter_config["patterns"]) do
      local pos, pattern = unpack(p)
      local d = dirs[i + pos]
      if d and d:match(pattern) then
        return dir
      end
    end
  end
  return nil
end

local function chdir()
  if not vim.tbl_contains({ "", "acwrite" }, vim.bo.buftype) then
    return
  end
  local base_path = vim.fn.expand("%:p:h", true)
  local root = find_root(base_path) or base_path
  if root ~= vim.fn.getcwd() then
    vim.api.nvim_set_current_dir(root)
  end
end

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  callback = chdir,
})
