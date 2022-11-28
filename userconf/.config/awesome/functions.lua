local awful = require("awful")
local menubar = require("menubar")
local vars = require("main.vars")
local beautiful = require("beautiful")

local client = client
local awesome = awesome
local unpack = table.unpack

local compositor = vars.compositor
local terminal = vars.terminal
local playerctl = vars.playerctl
local webbrowser = vars.webbrowser

local M = {}

M.show_help = require("awful.hotkeys_popup").show_help

local function cmd(command)
  return function()
    awful.spawn.with_shell(command)
  end
end

local function j(func, ...)
  local args = { ... }
  return function()
    func(unpack(args))
  end
end

local function screen_ratio()
  local geometry = awful.screen.focused().workarea
  return geometry.height / geometry.width
end

local function resize_float(c, x, y)
  local ratio = screen_ratio()
  x = x or 0
  y = y or 0
  local min_width = 400
  local min_height = min_width * ratio
  if c.width < min_width then
    x = math.max(x, 0)
  end
  if c.height < min_height then
    y = math.max(y, 0)
  end
  c:relative_move(-x, -y, 2 * x, 2 * y)
end

local function float_resize(c, width, height)
  c.floating = true
  c.width = width
  c.height = height
end

M.align = function(c, position)
  local geometry = c.screen.workarea
  local max_width = geometry.width
  local max_height = geometry.height
  local right = max_width - c.width
  local bottom = max_height - c.height
  local center_x = right * 0.5
  local center_y = bottom * 0.5
  local border_width = c._border_width or beautiful.border_width
  right = right - 2 * border_width
  bottom = bottom - 2 * border_width
  if position == "center" then
    c.x = center_x
    c.y = center_y
  end
  if position == "topleft" then
    c.x = 0
    c.y = 0
  end
  if position == "topright" then
    c.x = right
    c.y = 0
  end
  if position == "bottomleft" then
    c.x = 0
    c.y = bottom
  end
  if position == "bottomright" then
    c.x = right
    c.y = bottom
  end
  if position == "top" then
    c.x = center_x
    c.y = 0
  end
  if position == "right" then
    c.x = right
    c.y = center_y
  end
  if position == "bottom" then
    c.x = center_x
    c.y = bottom
  end
  if position == "left" then
    c.x = 0
    c.y = center_y
  end
end

M.client_fix = function(pos, width, height, sticky)
  return function(c)
    float_resize(c, width, height)
    M.align(c, pos)
    c.sticky = sticky
  end
end

M.right = function(c)
  local geometry = c.screen.workarea
  local border_width = c._border_width or beautiful.border_width
  local max_width = geometry.width - 2 * border_width
  local max_height = geometry.height - 2 * border_width
  float_resize(c, max_width / 2, max_height)
  M.align(c, "topright")
  c.sticky = true
end

M.right_sticky = function(c)
  M.right(c)
  c.sticky = true
end

M.toggle_sticky = function(c)
  if not c.floating then
    c.sticky = false
  else
    c.sticky = not c.sticky
  end
end

M.tag_viewer = function (i)
  return function()
    local screen = awful.screen.focused()
    local tag = screen.tags[i]
    if tag then
      tag:view_only()
    end
  end
end

M.tag_toggler = function (i);
  return function()
    local screen = awful.screen.focused()
    local tag = screen.tags[i]
    if tag then
      awful.tag.viewtoggle(tag)
    end
  end
end

M.tag_mover = function (i)
  return function()
    if client.focus then
      local tag = client.focus.screen.tags[i]
      if tag then
        client.focus:move_to_tag(tag)
      end
    end
  end
end

M.focus_toggler = function (i)
  return function()
    if client.focus then
      local tag = client.focus.screen.tags[i]
      if tag then
        client.focus:toggle_tag(tag)
      end
    end
  end
end

M.fullscreen = function (c)
  c.fullscreen = not c.fullscreen
  c:raise()
end

M.kill = function (c)
  c:kill()
end

M.toggle_float = function (c)
  c.floating = not c.floating
  local geometry = c.screen.geometry
  local border_width = c._border_width or beautiful.border_width
  local max_width = geometry.width - 2 * border_width
  local max_height = geometry.height - 2 * border_width
  if c.floating then
    if c.width > max_width then
      c.width = max_width
    end
    if c.height > max_height then
      c.height = max_height
    end
    if c.x + c.width > max_width then
      c.x = max_width - c.width
    end
    if c.y + c.height > max_height then
      c.y = max_height - c.height
    end
    if c.x < 0 then
      c.x = 0
    end
    if c.y < 0 then
      c.y = 0
    end
  end
end

M.getmaster = function (c)
  c:swap(awful.client.getmaster())
end

M.move_to_screen = function (c)
  c:move_to_screen()
end

M.ontop = function (c)
  c.ontop = not c.ontop
end

M.minimize = function (c)
  c.minimized = true
end

M.maximize = function (c)
  c.maximized = not c.maximized
  c:raise()
end

M.maximize_vertical = function (c)
  c.maximized_vertical = not c.maximized_vertical
  c:raise()
end

M.maximized_horizontal= function (c)
  c.maximized_horizontal = not c.maximized_horizontal
  c:raise()
end

M.show_menu = function ()
  require("main.menu"):show()
end

M.go_back = function ()
  awful.client.focus.history.previous()
  if client.focus then
    client.focus:raise()
  end
end

M.restore_minimized = function ()
  local c = awful.client.restore()
  -- Focus restored client
  if c then
    c:emit_signal("request::activate", "key.unminimize", { raise = true })
  end
end

M.execute_lua = function ()
  awful.prompt.run({
    prompt = "Run Lua code: ",
    textbox = awful.screen.focused().promptbox.widget,
    exe_callback = awful.util.eval,
    history_path = awful.util.get_cache_dir() .. "/history_eval",
  })
end

M.show_menubar = function()
  menubar.show()
end

M.toggle_menu = function()
  require("main.menu"):toggle()
end

M.focus_next = j(awful.client.focus.byidx, 1)
M.focus_prev = j(awful.client.focus.byidx, -1)
M.swap_next = j(awful.client.swap.byidx, 1)
M.swap_prev = j(awful.client.swap.byidx, -1)
M.focus_next_screen = j(awful.screen.focus_relative, 1)
M.focus_prev_screen = j(awful.screen.focus_relative, -1)
M.swap_top = j(awful.client.swap.bydirection, "up")
M.swap_bottom = j(awful.client.swap.bydirection, "down")
M.swap_left = function()
  local tag = awful.screen.focused().selected_tag
  if tag.layout.name == "max" then
    M.swap_prev()
  else
    awful.client.swap.bydirection("left")
  end
end
M.swap_right = function()
  local tag = awful.screen.focused().selected_tag
  if tag.layout.name == "max" then
    M.swap_next()
  else
    awful.client.swap.bydirection("right")
  end
end
M.focus_top = j(awful.client.focus.bydirection, "up")
M.focus_bottom = j(awful.client.focus.bydirection, "down")
M.focus_left = function()
  local tag = awful.screen.focused().selected_tag
  if tag.layout.name == "max" then
    M.focus_prev()
  else
    awful.client.focus.bydirection("left")
  end
end
M.focus_right = function()
  local tag = awful.screen.focused().selected_tag
  if tag.layout.name == "max" then
    M.focus_next()
  else
    awful.client.focus.bydirection("right")
  end
end
M.resize_grow = function(c)
  if c.floating then
    local ratio = screen_ratio()
    local x = 20
    local y = x * ratio - 0.5
    resize_float(c, x, y)
  else
    awful.tag.incmwfact(0.05)
  end
end
M.resize_shrink = function(c)
  if c.floating then
    local ratio = screen_ratio()
    local x = -20
    local y = x * ratio - 0.5
    resize_float(c, x, y)
  else
    awful.tag.incmwfact(-0.05)
  end
end
M.resize_grow_x = function(c)
  if c.floating then
    resize_float(c, 10, 0)
  end
end
M.resize_shrink_x = function(c)
  if c.floating then
    resize_float(c, -10, 0)
  end
end
M.inc_number_of_masters = j(awful.tag.incnmaster, 1, nil, true)
M.dec_number_of_masters = j(awful.tag.incnmaster, -1, nil, true)
M.inc_number_of_columns = j(awful.tag.incncol, 1, nil, true)
M.dec_number_of_columns = j(awful.tag.incncol, -1, nil, true)
M.grow_bottom = j(awful.client.moveresize, 0, 0, 0, 20)
M.shrink_bottom = j(awful.client.moveresize, 0, 0, 0, -20)
M.grow_left = j(awful.client.moveresize, -20, 0, 20, 0)
M.shrink_left = j(awful.client.moveresize, 0, 0, -20, 0)
M.grow_top = j(awful.client.moveresize, 0, -20, 0, 20)
M.shrink_top = j(awful.client.moveresize, 0, 20, 0, -20)
M.grow_right = j(awful.client.moveresize, 0, 0, 20, 0)
M.shrink_right = j(awful.client.moveresize, 20, 0, -20, 0)
M.prev_tag = awful.tag.viewprev
M.next_tag = awful.tag.viewnext
M.jump_to_urgent = awful.client.urgent.jumpto
M.restore_tag = awful.tag.history.restore
M.restart = awesome.restart
M.quit = awesome.quit
M.layout_tile = j(awful.layout.set, awful.layout.suit.tile)
M.layout_max = j(awful.layout.set, awful.layout.suit.max)
M.layout_bottom = j(awful.layout.set, awful.layout.suit.tile.bottom)
M.layout_fair = j(awful.layout.set, awful.layout.suit.fair)
M.layout_floating = j(awful.layout.set, awful.layout.suit.floating)
M.layout_magnifier = j(awful.layout.set, awful.layout.suit.magnifier)
M.layout_dwindle = j(awful.layout.set, awful.layout.suit.spiral.dwindle)

M.open_terminal = cmd(terminal)
M.inc_brightness_1 = cmd("xbacklight -time 0 +1")
M.dec_brightness_1 = cmd("xbacklight -time 0 -1")
M.inc_brightness_5 = cmd("xbacklight -time 0 +5")
M.dec_brightness_5 = cmd("xbacklight -time 0 -5")
M.rofi = cmd("rofi -show drun")
M.lock = cmd("playerctl -a pause ; exec i3lock -c 000000")
M.reboot = cmd("reboot")
M.toggle_audio = cmd("pamixer --toggle-mute")
M.toggle_mic = cmd("pamixer --source 1 --toggle-mute")
M.inc_volume = cmd("pamixer -i 5")
M.dec_volume = cmd("pamixer -d 5")
M.audio_next = cmd(playerctl .. " next")
M.audio_prev = cmd(playerctl .. " previous")
M.toggle_audio_program = cmd(playerctl .. " play-pause")
M.pause_audio_program = cmd(playerctl .. " pause")
M.toggle_lidswitch = cmd("~/.bin/nolidswitch")
local ensure_webbrowser = cmd("pgrep -u $UID " .. webbrowser .. " || " .. webbrowser)
local first_screen = M.tag_viewer(1)
function M.to_webbrowser_screen()
  ensure_webbrowser()
  first_screen()
end
M.open_filebrowser = cmd(vars.guifilebrowser)
M.screen_screenshot = cmd("screenshot -s")
M.window_screenshot = cmd("screenshot -w")
M.toggle_compositor = cmd("pkill -u $UID " .. compositor .. " || " .. compositor .. " -b")
M.toggle_auto_clicker = cmd("i3clicker")
M.toggle_color_picker = cmd("i3colorselect")
M.toggle_window_terminator = cmd("pkill -u $UID xkill || xkill")

local function focus(c)
  c:emit_signal("request::activate", "mouse_click", { raise = true })
end

M.click = focus

M.click_move = function (c)
  focus(c)
  awful.mouse.client.move(c)
end

M.click_resize = function (c)
  focus(c)
  awful.mouse.client.resize(c)
end

return M
