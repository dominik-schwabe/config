local F = require("user.functional")

function D(...)
  local tbl = F.map({ ... }, vim.inspect)
  if #tbl ~= 0 then
    print(unpack(tbl))
  else
    print("--- empty ---")
  end
end

function DK(list)
  if type(list) == "table" then
    D(F.keys(list))
  else
    print("--- object is not a table ---")
  end
end
