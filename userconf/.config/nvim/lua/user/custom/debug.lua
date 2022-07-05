local F = require("user.functional")

function Draw(...)
  return F.map({ ... }, vim.inspect)
end

function D(...)
  local tbl = Draw(...)
  print(#tbl ~= 0 and unpack(tbl) or "--- empty ---")
end

function DK(list)
  D(list ~= nil and F.keys(list) or nil)
end
