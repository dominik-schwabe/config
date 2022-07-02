local F = require("user.functional")

function D(...)
  local tbl = F.map({ ... }, vim.inspect)
  print(#tbl ~= 0 and unpack(tbl) or "--- empty ---")
end

function DK(list)
  D(list ~= nil and F.keys(list) or nil)
end
