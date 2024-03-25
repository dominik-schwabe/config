local M = {}

M.map = function(tbl, func)
  return vim.tbl_map(func, tbl)
end
M.filter = function(tbl, func)
  return vim.tbl_filter(func, tbl)
end
M.keys = vim.tbl_keys
M.contains = vim.tbl_contains

function M.foreach(list, cb)
  for _, value in ipairs(list) do
    cb(value)
  end
end

function M.entries(obj)
  local entries = {}
  for key, value in pairs(obj) do
    entries[#entries + 1] = { key, value }
  end
  return entries
end

function M.from_entries(list)
  local obj = {}
  for _, e in ipairs(list) do
    local key, value = unpack(e)
    obj[key] = value
  end
  return obj
end

function M.map_obj(obj, cb)
  return M.from_entries(M.map(M.entries(obj), function(item)
    local key, value = unpack(item)
    return cb(key, value)
  end))
end

function M.subset(obj, values)
  local new_obj = {}
  M.foreach(values, function(value)
    new_obj[value] = obj[value]
  end)
  return new_obj
end

function M.any(list, cb)
  for _, value in ipairs(list) do
    if cb(value) then
      return true
    end
  end
  return false
end

return M
