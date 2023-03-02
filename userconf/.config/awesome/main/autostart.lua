local awful = require("awful")
local F = require("util.functional")

local autostart_programs = {
  "brave",
  "sleep 2; easyeffects --gapplication-service",
  "sleep 2; unclutter --timeout 0.7",
  "sleep 2; flameshot",
  "sleep 4; birdtray",
  "sleep 5; spotify-launcher",
  "sleep 6; launch_discord",
  "sleep 8; telegram-desktop -startintray",
}

awful.spawn.easy_async_with_shell("xrdb -query | grep -q '^awesome\\.started:\\s*true$'", function(_, _, _, exit_code)
  if exit_code ~= 0 then
    F.foreach(autostart_programs, awful.spawn.with_shell)
    awful.spawn.with_shell("xrdb -merge <<< 'awesome.started:true'")
  end
end)
