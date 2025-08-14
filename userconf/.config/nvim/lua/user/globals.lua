local F = require("user.functional")

local function D(...)
  local tbl = vim.iter({ ... }):map(vim.inspect):totable()
  if #tbl ~= 0 then
    print(unpack(tbl))
  else
    print("--- empty ---")
  end
end

local function DK(list)
  if type(list) == "table" then
    D(vim.tbl_keys(list))
  else
    print("--- object is not a table ---")
  end
end

_G.f = F
_G.D = D
_G.DK = DK
