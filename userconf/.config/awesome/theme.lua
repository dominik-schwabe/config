local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local colors = require("colors")

local theme_path = require("awful.util").getdir("config") .. "/themes/default/"

local M = {}

M.font = "DejaVu Sans Mono 9"
M.taglist_font = "DejaVu Sans Mono 9"
M.useless_gap = 0

M.border_width = 1
M.border_single_client = false

-- "#dd5ddd"
-- "#00cc00"
-- "#ddad00"
-- "#5eaeee"
-- "#dd0000"
-- "#dddd00"
-- "#f92672"
-- "#00ffaf"
-- "#ae81ff"
-- "#00ddad"
M.border_normal = colors["grey800"]
M.border_focus = "#ae01ff"
M.border_focus_float = colors["red300"]
M.border_marked = colors["orange500"]

M.bg_normal = colors["white"] .. "cc"
M.bg_focus = colors["red300"] .. "cc"
M.bg_urgent = colors["orange900"] .. "cc"
M.bg_minimize = colors["grey500"] .. "cc"
M.bg_systray = colors["grey100"] .. "cc"

M.fg_normal = colors["black"]
M.fg_focus = colors["white"]
M.fg_urgent = colors["white"]
M.fg_minimize = colors["white"]

M.taglist_bg_focus = colors["red500"] .. "cc"
M.taglist_fg_focus = colors["white"]

local taglist_square_size = dpi(4)
M.taglist_squares_sel = theme_assets.taglist_squares_sel(taglist_square_size, colors["black"])
M.taglist_squares_unsel = theme_assets.taglist_squares_unsel(taglist_square_size, colors["white"])

M.tasklist_bg_normal = colors["white"] .. "88"
M.tasklist_bg_focus = colors["red300"] .. "88"
M.tasklist_fg_focus = colors["black"]

M.titlebar_bg_normal = colors["white"] .. "cc"
M.titlebar_bg_focus = colors["white"] .. "cc"
M.titlebar_fg_focus = colors["black"] .. "cc"

M.menu_submenu_icon = theme_path .. "misc/default/submenu.png"

M.menu_height = 20 -- dpi(15)
M.menu_width = 180 -- dpi(100)
-- M.menu_context_height = 20

M.menu_bg_normal = colors["white"] .. "cc"
M.menu_bg_focus = colors["red300"] .. "cc"
M.menu_fg_focus = colors["black"]

M.menu_border_color = colors["blue500"] .. "cc"
M.menu_border_width = 1

M.wallpaper = theme_path .. "background.jpg"
M.awesome_icon = theme_path .. "launcher/logo20_kali_black.png"
M.awesome_subicon = theme_path .. "launcher/logo20_kali_black.png"

M.systray_icon_spacing = 5

return M
