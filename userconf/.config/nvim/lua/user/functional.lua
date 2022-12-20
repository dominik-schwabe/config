local M = {}
local config = require("user.config")

function M.foreach(list, cb)
  for _, el in ipairs(list) do
    cb(el)
  end
end

function M.map(list, cb)
  local mapped = {}
  for _, el in ipairs(list) do
    mapped[#mapped + 1] = cb(el)
  end
  return mapped
end

function M.filter(list, cb)
  local filtered = {}
  for _, el in ipairs(list) do
    if cb(el) then
      filtered[#filtered + 1] = el
    end
  end
  return filtered
end

function M.find(list, cb)
  for _, el in ipairs(list) do
    if cb(el) then
      return el
    end
  end
end

function M.any(list, cb)
  for _, el in ipairs(list) do
    if cb(el) then
      return true
    end
  end
  return false
end

function M.all(list, cb)
  for _, el in ipairs(list) do
    if not cb(el) then
      return false
    end
  end
  return true
end

function M.keys(list)
  local keys = {}
  for key, _ in pairs(list) do
    keys[#keys + 1] = key
  end
  return keys
end

function M.values(list)
  local values = {}
  for _, el in pairs(list) do
    values[#values + 1] = el
  end
  return values
end

function M.contains(list, x)
  return M.any(list, function(el)
    return el == x
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
  return M.filter(list, function(v)
    return v ~= e
  end)
end

function M.concat(...)
  local new_table = {}
  for _, t in ipairs({ ... }) do
    for _, v in ipairs(t) do
      new_table[#new_table + 1] = v
    end
  end
  return new_table
end

function M.extend(list, ...)
  local new_table = list
  for _, t in ipairs({ ... }) do
    for _, v in ipairs(t) do
      new_table[#new_table + 1] = v
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

function M.split(str, sep)
  sep = sep or "%s"
  return M.consume(string.gmatch(str, "([^" .. sep .. "]+)"))
end

function M.load(src, cb)
  local success, pkg = pcall(require, src)
  if success then
    if cb then
      cb(pkg)
    end
    return pkg
  end
  if config.debug then
    print("loading '" .. src .. "' failed")
  end
  return nil
end

function M.loader(src, cb)
  return function()
    return M.load(src, cb)
  end
end

return M
