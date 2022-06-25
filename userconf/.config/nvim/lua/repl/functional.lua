local M = {}

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

function M.keys(list)
  local keys = {}
  for key, _ in pairs(list) do
    keys[#keys + 1] = key
  end
  return keys
end

function M.min(list)
  if #list > 0 then
    return math.min(unpack(list))
  end
  return nil
end

return M
