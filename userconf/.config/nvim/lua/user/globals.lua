local F = require("user.functional")

local function D(...)
  local tbl = F.map({ ... }, vim.inspect)
  if #tbl ~= 0 then
    print(unpack(tbl))
  else
    print("--- empty ---")
  end
end

local function DK(list)
  if type(list) == "table" then
    D(F.keys(list))
  else
    print("--- object is not a table ---")
  end
end

_G.f = F
_G.D = D
_G.DK = DK
