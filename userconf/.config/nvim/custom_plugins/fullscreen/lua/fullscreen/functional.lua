local M = {}

M.filter = function(tbl, func)
  return vim.tbl_filter(func, tbl)
end

function M.foreach(list, cb)
  for _, value in ipairs(list) do
    cb(value)
  end
end

function M.all(list, cb)
  for _, value in ipairs(list) do
    if not cb(value) then
      return false
    end
  end
  return true
end

return M
