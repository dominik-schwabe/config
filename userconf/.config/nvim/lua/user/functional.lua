local M = {}
local config = require("user.config")

local unpack = unpack

function M.foreach(list, cb)
  for _, value in ipairs(list) do
    cb(value)
  end
end

function M.map(list, cb)
  local mapped = {}
  for _, value in ipairs(list) do
    mapped[#mapped + 1] = cb(value)
  end
  return mapped
end

function M.filter(list, cb)
  local filtered = {}
  for _, value in ipairs(list) do
    if cb(value) then
      filtered[#filtered + 1] = value
    end
  end
  return filtered
end

function M.reduce(list, cb, default)
  local acc = default
  if acc == nil then
    acc = list[1]
    table.remove(list, 1)
  end
  for _, el in ipairs(list) do
    acc = cb(acc, el)
  end
  return acc
end

function M.sum(list)
  return M.reduce(list, function(a, b)
    return a + b
  end, 0)
end

function M.find(list, cb)
  for _, value in ipairs(list) do
    if cb(value) then
      return value
    end
  end
end

function M.any(list, cb)
  for _, value in ipairs(list) do
    if cb(value) then
      return true
    end
  end
  return false
end

function M.all(list, cb)
  for _, value in ipairs(list) do
    if not cb(value) then
      return false
    end
  end
  return true
end

function M.keys(obj)
  local keys = {}
  for key, _ in pairs(obj) do
    keys[#keys + 1] = key
  end
  return keys
end

function M.values(obj)
  local values = {}
  for _, value in pairs(obj) do
    values[#values + 1] = value
  end
  return values
end

function M.entries(obj)
  local entries = {}
  for key, value in pairs(obj) do
    entries[#entries + 1] = { key, value }
  end
  return entries
end

function M.contains(list, x)
  return M.any(list, function(value)
    return value == x
  end)
end

function M.min(list)
  if #list > 0 then
    return math.min(unpack(list))
  end
  return nil
end

function M.f(func, ...)
  local tbl = { ... }
  return function()
    return func(unpack(tbl))
  end
end

function M.chain(...)
  local funcs = { ... }
  return function()
    for _, func in ipairs(funcs) do
      func()
    end
  end
end

function M.remove(list, e)
  return M.filter(list, function(value)
    return value ~= e
  end)
end

function M.concat(...)
  local new_table = {}
  for _, t in ipairs({ ... }) do
    for _, value in ipairs(t) do
      new_table[#new_table + 1] = value
    end
  end
  return new_table
end

function M.extend(list, ...)
  local new_table = list
  for _, t in ipairs({ ... }) do
    for _, value in ipairs(t) do
      new_table[#new_table + 1] = value
    end
  end
  return new_table
end

function M.reverse(list)
  local reversed = {}
  for i = #list, 1, -1 do
    reversed[#reversed + 1] = list[i]
  end
  return reversed
end

function M.next(iter)
  for e in iter do
    return e
  end
  return nil
end

function M.consume(obj)
  local data = {}
  for e in obj do
    data[#data + 1] = e
  end
  return data
end

-- function M.split(str, sep)
--   sep = sep or "%s"
--   return M.consume(string.gmatch(str, "([^" .. sep .. "]+)"))
-- end

function M.slice(tbl, first, last, step)
  local sliced = {}
  for i = first or 1, last or #tbl, step or 1 do
    sliced[#sliced + 1] = tbl[i]
  end
  return sliced
end

function M.limit(tbl, upper)
  for i = upper + 1, #tbl, 1 do
    tbl[i] = nil
  end
  return tbl
end

function M.load(src, cb, silent)
  silent = silent == nil and true or silent
  local success, pkg = pcall(require, src)
  if success then
    if cb then
      cb(pkg)
    end
    return pkg
  end
  if config.log_level ~= nil and config.log_level ~= vim.log.levels.OFF then
    local command = "loading '" .. src .. "' failed"
    if config.log_level <= vim.log.levels.INFO then
      if not silent then
        vim.notify(command, config.log_level)
      end
    else
      command = command .. "\n" .. pkg
      vim.notify(command, config.log_level)
    end
  end
  return nil
end

return M
