local wezterm = require("wezterm")

local config = wezterm.config_builder and wezterm.config_builder() or {}

local LINK_RE = "(https?://[^ \t\n\"'()<>]+[/a-zA-Z0-9-]+)"

config.hyperlink_rules = {
  -- Matches: a URL in parens: (URL)
  { regex = "\\(" .. LINK_RE .. "\\)", format = "$1", highlight = 1 },
  -- Matches: a URL in brackets: [URL]
  { regex = "\\[" .. LINK_RE .. "\\]", format = "$1", highlight = 1 },
  -- Matches: a URL in curly braces: {URL}
  { regex = "\\{" .. LINK_RE .. "\\}", format = "$1", highlight = 1 },
  -- Matches: a URL in angle brackets: <URL>
  { regex = "<" .. LINK_RE .. ">", format = "$1", highlight = 1 },
  -- Then handle URLs not wrapped in brackets
  { regex = "\\b" .. LINK_RE, format = "$1", highlight = 1 },
  -- implicit mailto link
  { regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b", format = "mailto:$0" },
}

config.font = wezterm.font("Fira Code Nerd Font")
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
config.warn_about_missing_glyphs = false
config.font_size = 10.5
config.scrollback_lines = 10000
config.enable_tab_bar = false
config.disable_default_key_bindings = true
config.adjust_window_size_when_changing_font_size = false
config.bold_brightens_ansi_colors = "No"
config.window_padding = {
  left = 6,
  right = 6,
  top = 3,
  bottom = 3,
}

config.colors = {
  foreground = "silver",
  background = "#111111",

  cursor_bg = "#dddddd",
  cursor_fg = "#000000",
  cursor_border = "#dddddd",

  selection_fg = "black",
  selection_bg = "#cc8866",

  scrollbar_thumb = "#222222",

  split = "#444444",

  ansi = {
    "#444444",
    "#ff1111",
    "#83e516",
    "#ed9d12",
    "#5f87af",
    "#f92672",
    "#66d9ef",
    "#dddddd",
  },
  brights = {
    "#5f87af",
    "#ff3f3f",
    "#3fff3f",
    "#deed12",
    "#5f87af",
    "#f92672",
    "#66d9ef",
    "#dddddd",
  },

  indexed = {},

  compose_cursor = "orange",

  copy_mode_active_highlight_bg = { Color = "#000000" },
  -- use `AnsiColor` to specify one of the ansi color palette values
  -- (index 0-15) using one of the names "Black", "Maroon", "Green",
  --  "Olive", "Navy", "Purple", "Teal", "Silver", "Grey", "Red", "Lime",
  -- "Yellow", "Blue", "Fuchsia", "Aqua" or "White".
  copy_mode_active_highlight_fg = { AnsiColor = "Black" },
  copy_mode_inactive_highlight_bg = { Color = "#52ad70" },
  copy_mode_inactive_highlight_fg = { AnsiColor = "White" },

  quick_select_label_bg = { Color = "peru" },
  quick_select_label_fg = { Color = "#ffffff" },
  quick_select_match_bg = { AnsiColor = "Navy" },
  quick_select_match_fg = { Color = "#ffffff" },
}

local act = wezterm.action
config.keys = {
  { key = "+", mods = "CTRL", action = act.IncreaseFontSize },
  { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
  { key = "0", mods = "CTRL", action = act.ResetFontSize },
  { key = "C", mods = "SHIFT|CTRL", action = act.CopyTo("Clipboard") },
  { key = "F", mods = "SHIFT|CTRL", action = act.Search("CurrentSelectionOrEmptyString") },
  { key = "f", mods = "SHIFT|CTRL", action = act.Search("CurrentSelectionOrEmptyString") },
  { key = "V", mods = "SHIFT|CTRL", action = act.PasteFrom("Clipboard") },
  { key = "v", mods = "SHIFT|CTRL", action = act.PasteFrom("Clipboard") },
  { key = "C", mods = "SHIFT|CTRL", action = act.CopyTo("Clipboard") },
  { key = "c", mods = "SHIFT|CTRL", action = act.CopyTo("Clipboard") },
  { key = "PageUp", mods = "SHIFT", action = act.ScrollByPage(-1) },
  { key = "PageDown", mods = "SHIFT", action = act.ScrollByPage(1) },
  { key = "Insert", mods = "SHIFT", action = act.PasteFrom("PrimarySelection") },
  { key = "Insert", mods = "CTRL", action = act.CopyTo("PrimarySelection") },
  { key = "Copy", mods = "NONE", action = act.CopyTo("Clipboard") },
  { key = "Paste", mods = "NONE", action = act.PasteFrom("Clipboard") },
  { key = "phys:Space", mods = "SHIFT|CTRL", action = act.ActivateCopyMode },
  {
    key = "I",
    mods = "SHIFT|CTRL",
    action = act.CharSelect({ copy_on_select = true, copy_to = "ClipboardAndPrimarySelection" }),
  },
  { key = "K", mods = "SHIFT|CTRL", action = act.ShowDebugOverlay },
  -- { key = 'l', mods = 'SHIFT|CTRL', action = act.ShowDebugOverlay },
  -- { key = 'P', mods = 'SHIFT|CTRL', action = act.ActivateCommandPalette },
  -- { key = 'p', mods = 'SHIFT|CTRL', action = act.ActivateCommandPalette },
}

config.key_tables = {
  copy_mode = {
    { key = "Enter", mods = "NONE", action = act.CopyMode("MoveToStartOfNextLine") },
    { key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
    { key = "Space", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
    { key = "$", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
    { key = "$", mods = "SHIFT", action = act.CopyMode("MoveToEndOfLineContent") },
    { key = ",", mods = "NONE", action = act.CopyMode("JumpReverse") },
    { key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
    { key = ";", mods = "NONE", action = act.CopyMode("JumpAgain") },
    { key = "F", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = false } }) },
    { key = "F", mods = "SHIFT", action = act.CopyMode({ JumpBackward = { prev_char = false } }) },
    { key = "G", mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
    { key = "G", mods = "SHIFT", action = act.CopyMode("MoveToScrollbackBottom") },
    { key = "H", mods = "NONE", action = act.CopyMode("MoveToViewportTop") },
    { key = "H", mods = "SHIFT", action = act.CopyMode("MoveToViewportTop") },
    { key = "L", mods = "NONE", action = act.CopyMode("MoveToViewportBottom") },
    { key = "L", mods = "SHIFT", action = act.CopyMode("MoveToViewportBottom") },
    { key = "M", mods = "NONE", action = act.CopyMode("MoveToViewportMiddle") },
    { key = "M", mods = "SHIFT", action = act.CopyMode("MoveToViewportMiddle") },
    { key = "O", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
    { key = "O", mods = "SHIFT", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
    { key = "T", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
    { key = "T", mods = "SHIFT", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
    { key = "V", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Line" }) },
    { key = "V", mods = "SHIFT", action = act.CopyMode({ SetSelectionMode = "Line" }) },
    { key = "^", mods = "NONE", action = act.CopyMode("MoveToStartOfLineContent") },
    { key = "^", mods = "SHIFT", action = act.CopyMode("MoveToStartOfLineContent") },
    { key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
    { key = "b", mods = "ALT", action = act.CopyMode("MoveBackwardWord") },
    { key = "b", mods = "CTRL", action = act.CopyMode("PageUp") },
    { key = "c", mods = "CTRL", action = act.CopyMode("Close") },
    { key = "d", mods = "CTRL", action = act.CopyMode({ MoveByPage = 0.5 }) },
    { key = "e", mods = "NONE", action = act.CopyMode("MoveForwardWordEnd") },
    { key = "f", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = false } }) },
    { key = "f", mods = "ALT", action = act.CopyMode("MoveForwardWord") },
    { key = "f", mods = "CTRL", action = act.CopyMode("PageDown") },
    { key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
    { key = "g", mods = "CTRL", action = act.CopyMode("Close") },
    { key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
    { key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
    { key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
    { key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
    { key = "m", mods = "ALT", action = act.CopyMode("MoveToStartOfLineContent") },
    { key = "o", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEnd") },
    { key = "q", mods = "NONE", action = act.CopyMode("Close") },
    { key = "t", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = true } }) },
    { key = "u", mods = "CTRL", action = act.CopyMode({ MoveByPage = -0.5 }) },
    { key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
    { key = "v", mods = "CTRL", action = act.CopyMode({ SetSelectionMode = "Block" }) },
    { key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
    {
      key = "y",
      mods = "NONE",
      action = act.Multiple({ { CopyTo = "ClipboardAndPrimarySelection" }, { CopyMode = "Close" } }),
    },
    { key = "PageUp", mods = "NONE", action = act.CopyMode("PageUp") },
    { key = "PageDown", mods = "NONE", action = act.CopyMode("PageDown") },
    { key = "End", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
    { key = "Home", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
    { key = "LeftArrow", mods = "NONE", action = act.CopyMode("MoveLeft") },
    { key = "LeftArrow", mods = "ALT", action = act.CopyMode("MoveBackwardWord") },
    { key = "RightArrow", mods = "NONE", action = act.CopyMode("MoveRight") },
    { key = "RightArrow", mods = "ALT", action = act.CopyMode("MoveForwardWord") },
    { key = "UpArrow", mods = "NONE", action = act.CopyMode("MoveUp") },
    { key = "DownArrow", mods = "NONE", action = act.CopyMode("MoveDown") },
  },

  search_mode = {
    { key = "Enter", mods = "NONE", action = act.CopyMode("PriorMatch") },
    { key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
    { key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
    { key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
    { key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
    { key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },
    { key = "PageUp", mods = "NONE", action = act.CopyMode("PriorMatchPage") },
    { key = "PageDown", mods = "NONE", action = act.CopyMode("NextMatchPage") },
    { key = "UpArrow", mods = "NONE", action = act.CopyMode("PriorMatch") },
    { key = "DownArrow", mods = "NONE", action = act.CopyMode("NextMatch") },
  },
}

return config
