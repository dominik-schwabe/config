local gears = require("gears")
local bindkey = require("util.bindkey")

local f = require("functions")

local vars = require("main.vars")
local dropdown = require("dropdown")

local shift = { "Shift" }
local mod = { vars.modkey }
local mod_ctrl = { vars.modkey, "Control" }
local mod_shift = { vars.modkey, "Shift" }
local mod_shift_ctrl = { vars.modkey, "Control", "Shift" }

local dropdown_terminal_toggle = dropdown.build_toggle_dropdown({
  cmd = "alacritty -t ___dropdownterminal___ -o font.size=10",
  name = "___dropdownterminal___",
  border_width = 3,
  overlap = false,
  width = 0.85,
  height = 0.85,
  border_color = "#77aa00",
  group = "1",
})

local dropdown_ipython_toggle = dropdown.build_toggle_dropdown({
  cmd = "alacritty -t ___ipython_interpreter___ -o font.size=10 -e launch_ipython",
  name = "___ipython_interpreter___",
  border_width = 3,
  overlap = false,
  width = 0.85,
  height = 0.85,
  border_color = "#02b4ef",
  group = "1",
})

local todo_toggle = dropdown.build_toggle_dropdown({
  cmd = "alacritty -t ___todo___ -o font.size=10 -e nvim -u NONE "
    .. vars.home
    .. '/.todo --cmd "set clipboard=unnamedplus nowrap tabstop=2 shiftwidth=2 softtabstop=2 autoindent smartindent expandtab ignorecase" --cmd "au TextChanged * write" --cmd "au VimLeavePre * write" --cmd "noremap Q :xa<cr>"',
  name = "___todo___",
  border_width = 3,
  overlap = false,
  width = 0.85,
  height = 0.85,
  border_color = "#77aa00",
  group = "1",
})

local cmus_toggle = dropdown.build_toggle_dropdown({
  cmd = "alacritty -t ___musicplayer___ -e cmus",
  name = "___musicplayer___",
  border_width = 3,
  overlap = false,
  width = 0.9,
  height = 0.9,
  border_color = "#77aa00",
  group = "1",
})

local thunderbird_toggle = dropdown.build_toggle_dropdown({
  instance = "Mail",
  class = "thunderbird",
  name = ".*Mozilla Thunderbird",
  border_width = 3,
  overlap = false,
  width = 0.9,
  height = 0.9,
  border_color = "#02b4ef",
  group = "1",
})

local globalkeys = gears.table.join(
  bindkey("awesome", mod, "s", f.show_help, "show help"),

  -- Tag browsing
  -- bindkey("tag", mod, "h", f.prev_tag, "view previous"),
  -- bindkey("tag", mod, "l", f.next_tag, "view next"),
  bindkey("tag", mod, "Tab", f.restore_tag, "go back"),
  bindkey("client", mod, "k", f.focus_top, "focus the top client"),
  bindkey("client", mod, "j", f.focus_bottom, "focus the bottom client"),
  bindkey("client", mod, "h", f.focus_left, "focus the left client"),
  bindkey("client", mod, "l", f.focus_right, "focus the right client"),
  bindkey("client", mod_shift, "h", f.swap_left, "focus the left client"),
  bindkey("client", mod_shift, "j", f.swap_bottom, "focus the bottom client"),
  bindkey("client", mod_shift, "k", f.swap_top, "focus the top client"),
  bindkey("client", mod_shift, "l", f.swap_right, "focus the right client"),
  bindkey("layout", mod, "e", f.layout_tile, "tile layout"),
  bindkey("layout", mod, "w", f.layout_max, "max layout"),
  bindkey("layout", mod, "q", f.layout_bottom, "bottom layout"),
  bindkey("layout", mod, "a", f.layout_fair, "fair layout"),

  bindkey("dropdown", mod, "asciicircum", dropdown_terminal_toggle, "toggle the dropdown terminal"),
  bindkey("dropdown", mod, "F1", dropdown_ipython_toggle, "toggle a ipython interpreter"),
  bindkey("dropdown", mod, "F12", todo_toggle, "open a todo scratchpad"),
  bindkey("dropdown", mod, "adiaeresis", thunderbird_toggle, "pull thunderbird to the front"),
  bindkey("dropdown", mod_shift, "y", cmus_toggle, "show the cmus music player"),

  -- Layout manipulation
  -- bindkey("screen", mod_ctrl, "j", f.focus_next_screen, "focus the next screen"),
  -- bindkey("screen", mod_ctrl, "k", f.focus_prev_screen, "focus the previous screen"),
  bindkey("client", mod, "u", f.jump_to_urgent, "jump to urgent client"),

  -- Standard program
  bindkey("launcher", mod, "Return", f.open_terminal, "open a terminal"),
  bindkey("awesome", mod_shift, "r", f.restart, "reload awesome"),
  bindkey("awesome", mod_shift, "Delete", f.quit, "quit awesome"),
  bindkey("awesome", mod_shift_ctrl, "Delete", f.reboot, "reboot the system"),

  bindkey("layout", mod_shift, "t", f.inc_number_of_masters, "increase the number of master clients"),
  bindkey("layout", mod_shift, "z", f.dec_number_of_masters, "decrease the number of master clients"),
  -- bindkey("layout", mod_ctrl, "h", f.inc_number_of_columns, "increase the number of columns"),
  -- bindkey("layout", mod_ctrl, "l", f.dec_number_of_columns, "decrease the number of columns"),

  bindkey("client", mod, "n", f.restore_minimized, "restore minimized"),

  -- Resize
  bindkey("client", mod, "Down", f.grow_bottom, "shrink the bottom of the window"),
  bindkey("client", mod, "Up", f.grow_top, "grow the bottom of the window"),
  bindkey("client", mod, "Left", f.grow_left, "shrink the left of the window"),
  bindkey("client", mod, "Right", f.grow_right, "grow the left of the window"),
  bindkey("client", mod_shift, "Down", f.shrink_top, "shrink the top of the window"),
  bindkey("client", mod_shift, "Up", f.shrink_bottom, "grow the top of the window"),
  bindkey("client", mod_shift, "Left", f.shrink_left, "shrink the right of the window"),
  bindkey("client", mod_shift, "Right", f.shrink_right, "grow the right of the window"),

  -- Prompt
  bindkey("launcher", mod, "d", f.rofi, "run prompt"),
  -- Lua code
  bindkey("awesome", mod, "F9", f.execute_lua, "execute lua code"),
  -- Menubar
  -- bindkey("launcher", mod, "p", f.show_menubar, "show the menubar"),

  bindkey("backlight", mod, "Home", f.inc_brightness_1, "increase the screen brightness by 1%"),
  bindkey("backlight", mod, "End", f.dec_brightness_1, "decrease the screen brightness by 1%"),
  bindkey("backlight", {}, "XF86MonBrightnessUp", f.inc_brightness_5, "increase the screen brightness by 5%"),
  bindkey("backlight", {}, "XF86MonBrightnessDown", f.dec_brightness_5, "decrease the screen brightness by 5%"),
  bindkey("awesome", {}, "XF86ScreenSaver ", f.lock, "lock the screen"),
  bindkey("audio", {}, "XF86AudioMute", f.toggle_audio, "toggle the audio output"),
  bindkey("audio", {}, "XF86AudioMicMute", f.toggle_mic, "toggle the microphone"),
  bindkey("audio", {}, "XF86AudioRaiseVolume", f.inc_volume, "increase the volume by 5%"),
  bindkey("audio", {}, "XF86AudioLowerVolume", f.dec_volume, "decrease the volume by 5%"),
  bindkey("audio", mod, "m", f.inc_volume, "increase the volume by 5%"),
  bindkey("audio", mod, "n", f.dec_volume, "decrease the volume by 5%"),
  bindkey("audio", {}, "XF86AudioNext", f.audio_next, "play the next track"),
  bindkey("audio", {}, "XF86AudioPrev", f.audio_prev, "play the previous track"),
  bindkey("audio", {}, "XF86AudioPlay", f.toggle_audio_program, "start/stop the audio"),
  bindkey("audio", {}, "XF86AudioStop", f.pause_audio_program, "stop the audio"),
  bindkey("audio", mod, "less", f.audio_prev, "play the previous track"),
  bindkey("audio", mod, "y", f.toggle_audio_program, "start/stop the audio"),
  bindkey("audio", mod, "x", f.audio_next, "play the next track"),
  bindkey("misc", {}, "XF86Launch1", f.toggle_lidswitch, "toggle the suspense trigger of closing the lid"),
  bindkey("tag", mod, "odiaeresis", f.to_webbrowser_screen, "focus the webbrowser screen"),
  bindkey("launcher", mod_shift, "Return", f.open_filebrowser, "open the graphical file browser"),
  bindkey("screenshot", {}, "Print", f.screen_screenshot, "take a screenshot of the entire screen"),
  bindkey("screenshot", shift, "Print", f.window_screenshot, "take a screenshot of the focused window"),
  -- bindsym $mod+udiaeresis move workspace to output next -- TODO: move output
  bindkey("launcher", mod, "F8", f.toggle_compositor, "toggle the compositor"),
  bindkey("launcher", mod_shift, "c", f.toggle_auto_clicker, "toggle an auto clicker"),
  bindkey("launcher", mod, "c", f.toggle_color_picker, "toggle the color picker"),

  bindkey("launcher", mod, "Delete", f.toggle_window_terminator, "toggle the window terminator")
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 7 do
  local tag = "#" .. i + 9
  globalkeys = gears.table.join(
    globalkeys,
    bindkey("tag", mod, tag, f.tag_viewer(i), "view tag #" .. i),
    bindkey("tag", mod_ctrl, tag, f.tag_toggler(i), "toggle tag #" .. i),
    bindkey("tag", mod_shift, tag, f.tag_mover(i), "move focused client to tag #" .. i),
    bindkey("tag", mod_shift_ctrl, tag, f.focus_toggler(i), "toggle focused client on tag #" .. i)
  )
end

for k, v in pairs({ o = 2, i = 3, u = 4, p = 7 }) do
  globalkeys = gears.table.join(
    globalkeys,
    bindkey("tag", mod, k, f.tag_viewer(v), "view tag #" .. v),
    bindkey("tag", mod_ctrl, k, f.tag_toggler(v), "toggle tag #" .. v),
    bindkey("tag", mod_shift, k, f.tag_mover(v), "move focused client to tag #" .. v),
    bindkey("tag", mod_shift_ctrl, k, f.focus_toggler(v), "toggle focused client on tag #" .. v)
  )
end

return globalkeys
