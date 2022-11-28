local awful = require("awful")
local F = require("util.functional")

local autostart_programs = {
  "brave",
  "sleep 1; spotify",
  "launch_discord",
  "telegram-desktop -startintray",
  "flameshot",
  "birdtray",
  "unclutter --timeout 0.7"
}

awful.spawn.easy_async_with_shell("xrdb -query | grep -q '^awesome\\.started:\\s*true$'", function(_, _, _, exit_code)
  if exit_code ~= 0 then
    F.foreach(autostart_programs, awful.spawn.with_shell)
    awful.spawn.with_shell("xrdb -merge <<< 'awesome.started:true'")
  end
end)
