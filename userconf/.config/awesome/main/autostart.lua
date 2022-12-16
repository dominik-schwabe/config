local awful = require("awful")
local F = require("util.functional")

local autostart_programs = {
  "brave",
  "sleep 2; easyeffects --gapplication-service",
  "sleep 2; unclutter --timeout 0.7",
  "sleep 2; flameshot",
  "sleep 2; spotify-launcher",
  "sleep 5; telegram-desktop -startintray",
  "sleep 5; launch_discord",
  "sleep 7; birdtray",
}

awful.spawn.easy_async_with_shell("xrdb -query | grep -q '^awesome\\.started:\\s*true$'", function(_, _, _, exit_code)
  if exit_code ~= 0 then
    F.foreach(autostart_programs, awful.spawn.with_shell)
    awful.spawn.with_shell("xrdb -merge <<< 'awesome.started:true'")
  end
end)
