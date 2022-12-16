local naughty = require("naughty")

local awesome = awesome

if awesome.startup_errors then
  naughty.notify({
    preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors,
  })
end

-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal("debug::error", function(err)
    -- Make sure we don't go into an endless error loop
    if in_error then
      return
    end
    in_error = true

    naughty.notify({
      preset = naughty.config.presets.critical,
      title = "Oops, an error happened! (error)",
      text = tostring(err),
    })
    in_error = false
  end)
end

do
  local in_error = false
  awesome.connect_signal("debug::deprecation", function(err)
    -- Make sure we don't go into an endless error loop
    if in_error then
      return
    end
    in_error = true

    naughty.notify({
      preset = naughty.config.presets.critical,
      title = "Oops, an error happened! (deprecation)",
      text = tostring(err),
    })
    in_error = false
  end)
end

do
  local in_error = false
  awesome.connect_signal("debug::index::miss", function(err)
    -- Make sure we don't go into an endless error loop
    if in_error then
      return
    end
    in_error = true

    naughty.notify({
      preset = naughty.config.presets.critical,
      title = "Oops, an error happened! (index::miss)",
      text = tostring(err),
    })
    in_error = false
  end)
end

do
  local in_error = false
  awesome.connect_signal("debug::newindex::miss", function(err)
    -- Make sure we don't go into an endless error loop
    if in_error then
      return
    end
    in_error = true

    naughty.notify({
      preset = naughty.config.presets.critical,
      title = "Oops, an error happened! (newindex::miss)",
      text = tostring(err),
    })
    in_error = false
  end)
end
