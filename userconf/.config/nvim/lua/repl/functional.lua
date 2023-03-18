local M = {}

M.map = function(tbl, func)
  return vim.tbl_map(func, tbl)
end
M.filter = function(tbl, func)
  return vim.tbl_filter(func, tbl)
end
M.keys = vim.tbl_keys

function M.min(list)
  if #list > 0 then
    return math.min(unpack(list))
  end
  return nil
end

function M.foreach(list, cb)
  for _, el in ipairs(list) do
    cb(el)
  end
end

return M
