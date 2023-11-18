local M = {}
local config = require("user.config")

M.map = function(tbl, func)
  return vim.tbl_map(func, tbl)
end
M.filter = function(tbl, func)
  return vim.tbl_filter(func, tbl)
end
M.keys = vim.tbl_keys
M.values = vim.tbl_values
M.contains = vim.tbl_contains

function M.iter(tbl)
  local i, v = next(tbl, nil)
  return function()
    local prev = v
    i, v = next(tbl, i)
    return prev
  end
end

function M.filter_map(list, cb)
  local mapped = {}
  for _, value in ipairs(list) do
    local result = cb(value)
    if result ~= nil then
      mapped[#mapped + 1] = result
    end
  end
  return mapped
end

function M.foreach(list, cb)
  for _, value in ipairs(list) do
    cb(value)
  end
end

function M.flat(list_of_lists)
  local result = {}
  for _, list in ipairs(list_of_lists) do
    for _, e in ipairs(list) do
      result[#result + 1] = e
    end
  end
  return result
end

function M.map_obj(obj, cb)
  local new_obj = {}
  for key, value in pairs(obj) do
    new_obj[key] = cb(value)
  end
  return new_obj
end

function M.foreach_items(obj, cb)
  for key, value in pairs(obj) do
    cb(key, value)
  end
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

function M.find_index(list, cb)
  for index, value in ipairs(list) do
    if cb(value) then
      return index
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

function M.entries(obj)
  local entries = {}
  for key, value in pairs(obj) do
    entries[#entries + 1] = { key, value }
  end
  return entries
end

function M.max(list)
  if #list > 0 then
    return math.max(unpack(list))
  end
  return nil
end

function M.min(list)
  if #list > 0 then
    return math.min(unpack(list))
  end
  return nil
end

function M.subset(obj, values)
  local new_obj = {}
  M.foreach(values, function(value)
    new_obj[value] = obj[value]
  end)
  return new_obj
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
  local list = {}
  for _, t in ipairs({ ... }) do
    for _, value in ipairs(t) do
      list[#list + 1] = value
    end
  end
  return list
end
function M.concat_inplace(list, ...)
  for _, t in ipairs({ ... }) do
    for _, value in ipairs(t) do
      list[#list + 1] = value
    end
  end
end

function M.extend(...)
  local obj = {}
  for _, t in pairs({ ... }) do
    for key, value in pairs(t) do
      obj[key] = value
    end
  end
  return obj
end

function M.extend_inplace(obj, ...)
  for _, t in pairs({ ... }) do
    for key, value in pairs(t) do
      obj[key] = value
    end
  end
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

function M.copy(obj)
  local new_obj = {}
  for key, value in pairs(obj) do
    new_obj[key] = value
  end
  return setmetatable(new_obj, getmetatable(obj))
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
  if not silent or config.log_level >= vim.log.levels.WARN then
    local command = "loading '" .. src .. "' failed"
    if (not silent and config.log_level >= vim.log.levels.INFO) or config.log_level >= vim.log.levels.ERROR then
      command = command .. "\n" .. pkg
      vim.notify(command, vim.log.levels.ERROR)
    else
      vim.notify(command, vim.log.levels.WARN)
    end
  end
  return nil
end

function M.sorted_find(tbl, el)
  local lower = 1
  local upper = #tbl + 1
  while lower < upper do
    local mid = math.floor((lower + upper) / 2)
    if tbl[mid] == el then
      return true, mid
    elseif tbl[mid] < el then
      lower = mid + 1
    else
      upper = mid
    end
  end
  return false, upper
end

function M.unique(list)
  local unique_keys = {}
  M.foreach(list, function(e)
    unique_keys[e] = e
  end)
  return M.keys(unique_keys)
end

function M.merge_sorted(tbl1, tbl2, opts)
  opts = opts or {}
  local unique = opts.unique
  local new_tbl = {}
  local tbl1_iter = M.iter(tbl1)
  local tbl2_iter = M.iter(tbl2)
  local e1 = tbl1_iter()
  local e2 = tbl2_iter()
  local last = nil
  local function add_e1()
    if not unique or e1 ~= last then
      new_tbl[#new_tbl + 1] = e1
    end
    last = e1
    e1 = tbl1_iter()
  end
  local function add_e2()
    if not unique or e2 ~= last then
      new_tbl[#new_tbl + 1] = e2
    end
    last = e2
    e2 = tbl2_iter()
  end
  while e1 or e2 do
    if e1 == nil then
      add_e2()
    elseif e2 == nil then
      add_e1()
    else
      if e1 < e2 then
        add_e1()
      else
        add_e2()
      end
    end
    last = new_tbl[#new_tbl]
  end
  return new_tbl
end

function M.threshold(thresholds, value)
  local found, upper = M.sorted_find(thresholds, value)
  local index = upper - 1
  if found then
    index = index + 1
  end
  return index
end

function M.set_timeout(callback, timeout)
  local timer = vim.loop.new_timer()
  timer:start(timeout or 0, 0, function()
    timer:stop()
    timer:close()
    callback()
  end)
  return timer
end

function M.clear_timeout(timer)
  if timer and not timer:is_closing() then
    timer:stop()
    timer:close()
  end
end

function M.defer(func, timeout)
  local timer = nil
  local function deferred_func(...)
    local args = { ... }
    M.clear_timeout(timer)
    timer = M.set_timeout(
      vim.schedule_wrap(function()
        func(unpack(args))
      end),
      timeout
    )
  end
  return deferred_func
end

function M.cache(func)
  local cached = nil
  return function()
    if not cached then
      cached = func()
    end
    return cached
  end
end

return M
