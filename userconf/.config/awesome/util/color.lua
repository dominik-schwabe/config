local M = {}

function M.fg(color, text)
    return string.format("<span foreground='%s'>%s</span>", color, text)
end

-- Set the background
function M.bg(color, text)
    return string.format("<span background='%s'>%s</span>", color, text)
end

-- Set foreground and background
function M.color(fg, bg, text)
    return string.format("<span foreground='%s' background='%s'>%s</span>", fg, bg, text)
end

return M
