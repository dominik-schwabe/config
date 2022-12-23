local History = {}
History.__index = History

function History:new(o)
  local obj = {}
  return setmetatable(obj, self)
end

