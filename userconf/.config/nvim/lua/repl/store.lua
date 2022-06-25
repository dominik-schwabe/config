local M = {}

M.callbacks = {}

function M.set_callbacks(add_callbacks)
  for key, _ in pairs(M.callbacks) do
    M.callbacks[key] = nil
  end
  for key, value in pairs(require("repl.callbacks").default_callbacks) do
    M.callbacks[key] = value
  end
  if add_callbacks ~= nil then
    for key, value in pairs(M.add_callbacks) do
      M.callbacks[key] = value
    end
  end
end

return M
