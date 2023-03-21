local awful = require("awful")
local F = require("util.functional")

local autostart_programs = {
  { 0, "brave &>/dev/null" },
  { 2, "easyeffects --gapplication-service" },
  { 3, "unclutter --timeout 0.7" },
  { 4, "spotify-launcher &>/dev/null" },
  { 6, "flameshot" },
  { 8, "birdtray" },
  { 10, "launch_discord" },
  { 12, "telegram-desktop -startintray" },
}

awful.spawn.easy_async_with_shell("xrdb -query | grep -q '^awesome\\.started:\\s*true$'", function(_, _, _, exit_code)
  if exit_code ~= 0 then
    F.foreach(autostart_programs, function(args)
      local timeout, program = table.unpack(args)
      F.schedule(function()
        awful.spawn.with_shell(program)
      end, timeout)
    end)
    awful.spawn.with_shell("xrdb -merge <<< 'awesome.started:true'")
  end
end)
