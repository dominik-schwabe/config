local F = require("user.functional")
local utils = require("user.utils")

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
