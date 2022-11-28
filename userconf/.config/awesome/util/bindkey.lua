local awful = require("awful")

return function (group, modifiers, key, func, description)
  return awful.key(modifiers, key, func, { description = description, group = group })
end
