local M = {}

function M.foreach(list, cb)
  for i, el in ipairs(list) do
    cb(el, i)
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

function M.dict(list)
  local data = {}
  M.foreach(list, function(e)
    local key, value = table.unpack(e)
    data[key] = value
  end)
  return data
end

function M.consume(obj)
  local data = {}
  for e in obj do
    data[#data + 1] = e
  end
  return data
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

function M.keys(obj)
  local keys = {}
  for key, _ in pairs(obj) do
    keys[#keys + 1] = key
  end
  return keys
end

function M.values(obj)
  local values = {}
  for _, el in pairs(obj) do
    values[#values + 1] = el
  end
  return values
end

function M.entries(obj)
  local entries = {}
  for key, el in pairs(obj) do
    entries[#entries + 1] = { key, el }
  end
  return entries
end

function M.contains(list, x)
  return M.any(list, function(el)
    return el == x
  end)
end

function M.min(list)
  if #list > 0 then
    return math.min(table.unpack(list))
  end
  return nil
end

function M.f(func, ...)
  local tbl = { ... }
  return function()
    return func(table.unpack(tbl))
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

function M.next(iter)
  for e in iter do
    return e
  end
  return nil
end

function M.call(cb)
  cb()
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

function M.compress(obj)
  local entries = M.entries(obj)
  table.sort(entries, function(a, b)
    return a[1] < b[1]
  end)
  return M.map(entries, function(e)
    return e[2]
  end)
end

function M.load(src, cb)
  local success, pkg = pcall(require, src)
  if success then
    if cb then
      cb(pkg)
    end
    return pkg
  end
  if require("main.vars").debug then
    require("notify").error("loading '" .. src .. "' failed")
  end
  return nil
end

return M
