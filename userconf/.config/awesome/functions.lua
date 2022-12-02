local F = require("util.functional")

local awful = require("awful")
local menubar = require("menubar")
local vars = require("main.vars")
local beautiful = require("beautiful")
local events = require("events")

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

local function _volume_notify()
  awful.spawn.easy_async("sleep 0.05", function(_, _, _, _)
    events.call("volume")
  end)
end

local function build_resizer(x, y, width, height)
  return function(c)
    c.x = c.x + x
    c.y = c.y + y
    c.width = c.width + width
    c.height = c.height + height
  end
end

local function move(c, rel_x, rel_y)
  if not c.fullscreen then
    c.x = c.x + rel_x
    c.y = c.y + rel_y
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

M.set_geometry = function(c, config)
  config = config or {}
  local overlap = config.overlap or false
  local width = config.width
  local height = config.height
  local border_width = config.border_width or c.border_width
  local alignment = config.alignment or "center"

  local sel = overlap and "geometry" or "workarea"
  local geom = awful.screen.focused()[sel]
  local new_width = width
  local new_height = height
  if width <= 1 then
    new_width = math.floor(geom.width * width) - 2 * border_width
  end
  if height <= 1 then
    new_height = math.floor(geom.height * height) - 2 * border_width
  end
  c.width = new_width
  c.height = new_height
  M.align(c, { alignment = alignment, overlap = overlap })
end

M.align = function(c, config)
  local border_width = c._border_width or beautiful.border_width
  local alignment = config.alignment or "center"
  local overlap = config.overlap or false
  local sel = overlap and "geometry" or "workarea"
  local geo = c.screen[sel]
  local right = geo.width - 2 * border_width - c.width
  local bottom = geo.height - 2 * border_width - c.height
  local center_x = right * 0.5
  local center_y = bottom * 0.5
  if alignment == "center" then
    c.x = geo.x + center_x
    c.y = geo.y + center_y
  end
  if alignment == "topleft" then
    c.x = geo.x
    c.y = geo.y
  end
  if alignment == "topright" then
    c.x = right
    c.y = geo.y
  end
  if alignment == "bottomleft" then
    c.x = geo.x
    c.y = bottom
  end
  if alignment == "bottomright" then
    c.x = right
    c.y = bottom
  end
  if alignment == "top" then
    c.x = geo.x + center_x
    c.y = geo.y
  end
  if alignment == "right" then
    c.x = right
    c.y = geo.y + center_y
  end
  if alignment == "bottom" then
    c.x = geo.x + center_x
    c.y = bottom
  end
  if alignment == "left" then
    c.x = geo.x
    c.y = geo.y + center_y
  end
end

M.dc = function(c)
  if type(c) == "string" then
    c = F.filter(client.get(), function(e)
      return e.instance == c
    end)[1]
    if not c then
      return "no client found"
    end
  end
  if not c then
    c = client.focus
  end
  return {
    name = c.name,
    skip_taskbar = c.skip_taskbar,
    type = c.type,
    class = c.class,
    instance = c.instance,
    pid = c.pid,
    role = c.role,
    hidden = c.hidden,
    minimized = c.minimized,
    size_hints_honor = c.size_hints_honor,
    border_width = c.border_width,
    border_color = c.border_color,
    urgent = c.urgent,
    ontop = c.ontop,
    above = c.above,
    below = c.below,
    fullscreen = c.fullscreen,
    maximized = c.maximized,
    maximized_horizontal = c.maximized_horizontal,
    maximized_vertical = c.maximized_vertical,
    transient_for = c.transient_for,
    group_window = c.group_window,
    leader_window = c.leader_window,
    sticky = c.sticky,
    modal = c.modal,
    focusable = c.focusable,
    startup_id = c.startup_id,
    valid = c.valid,
    marked = c.marked,
    is_fixed = c.is_fixed,
    immobilized = c.immobilized,
    floating = c.floating,
    x = c.x,
    y = c.y,
    width = c.width,
    height = c.height,
    dockable = c.dockable,
    requests_no_titlebar = c.requests_no_titlebar,
    window = c.window,
  }
end

M.focused_tag = function()
  return awful.screen.focused().selected_tag
end

M.move_to_tag_name = function(c, tagname)
  local tag = awful.tag.find_by_name(awful.screen[1], tagname)
  c:move_to_tag(tag)
end

M.client_fix = function(pos, width, height, sticky)
  return function(c)
    c.floating = true
    c.sticky = sticky
    M.set_geometry(c, { width = width, height = height, alignment = pos })
  end
end

M.right = function(c)
  c.floating = true
  c.sticky = true
  M.set_geometry(c, { width = 0.5, height = 1, alignment = "topright" })
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

M.tag_viewer = function(i)
  return function()
    local screen = awful.screen.focused()
    local tag = screen.tags[i]
    if tag then
      tag:view_only()
    end
  end
end

M.tag_toggler = function(i)
  return function()
    local screen = awful.screen.focused()
    local tag = screen.tags[i]
    if tag then
      awful.tag.viewtoggle(tag)
    end
  end
end

M.tag_mover = function(i)
  return function()
    if client.focus then
      local tag = client.focus.screen.tags[i]
      if tag then
        client.focus:move_to_tag(tag)
      end
    end
  end
end

M.focus_toggler = function(i)
  return function()
    if client.focus then
      local tag = client.focus.screen.tags[i]
      if tag then
        client.focus:toggle_tag(tag)
      end
    end
  end
end

M.fullscreen = function(c)
  c.fullscreen = not c.fullscreen
  c:raise()
end

M.kill = function(c)
  c:kill()
end

M.toggle_float = function(c)
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

  if not c.floating then
    c.sticky = false
    local tag = awful.screen.focused().selected_tag
    if tag then
      c:move_to_tag(tag)
    end
  end
end

M.getmaster = function(c)
  c:swap(awful.client.getmaster())
end

M.move_to_screen = function(c)
  c:move_to_screen()
end

M.ontop = function(c)
  c.ontop = not c.ontop
end

M.show_menu = function()
  require("main.menu"):show()
end

M.go_back = function()
  awful.client.focus.history.previous()
  if client.focus then
    client.focus:raise()
  end
end

M.restore_minimized = function()
  local c = awful.client.restore()
  -- Focus restored client
  if c then
    c:emit_signal("request::activate", "key.unminimize", { raise = true })
  end
end

M.execute_lua = function()
  awful.prompt.run({
    prompt = " Run Lua code: ",
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
  local tag = M.focused_tag()
  if tag.layout.name == "max" then
    M.swap_prev()
  else
    awful.client.swap.bydirection("left")
  end
end
M.swap_right = function()
  local tag = M.focused_tag()
  if tag.layout.name == "max" then
    M.swap_next()
  else
    awful.client.swap.bydirection("right")
  end
end
M.move_left = function(c)
  move(c, -50, 0)
end
M.move_top = function(c)
  move(c, 0, -50)
end
M.move_right = function(c)
  move(c, 50, 0)
end
M.move_bottom = function(c)
  move(c, 0, 50)
end
M.swap_resize_left = function(c)
  if c.floating then
    M.move_left(c)
  else
    M.swap_left()
  end
end
M.swap_resize_top = function(c)
  if c.floating then
    M.move_top(c)
  else
    M.swap_top()
  end
end
M.swap_resize_right = function(c)
  if c.floating then
    M.move_right(c)
  else
    M.swap_right()
  end
end
M.swap_resize_bottom = function(c)
  if c.floating then
    M.move_bottom(c)
  else
    M.swap_bottom()
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
M.grow_bottom = build_resizer(0, 0, 0, 20)
M.shrink_bottom = build_resizer(0, 0, 0, -20)
M.grow_left = build_resizer(-20, 0, 20, 0)
M.shrink_left = build_resizer(0, 0, -20, 0)
M.grow_top = build_resizer(0, -20, 0, 20)
M.shrink_top = build_resizer(0, 20, 0, -20)
M.grow_right = build_resizer(0, 0, 20, 0)
M.shrink_right = build_resizer(20, 0, -20, 0)
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
M.toggle_audio = F.chain(cmd("pamixer --toggle-mute"), _volume_notify)
M.toggle_mic = F.chain(cmd("pamixer --source 1 --toggle-mute"), _volume_notify)
M.inc_volume = F.chain(cmd("pamixer -i 5"), _volume_notify)
M.dec_volume = F.chain(cmd("pamixer -d 5"), _volume_notify)
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

M.click_move = function(c)
  focus(c)
  awful.mouse.client.move(c)
end

M.click_resize = function(c)
  focus(c)
  awful.mouse.client.resize(c)
end

return M
