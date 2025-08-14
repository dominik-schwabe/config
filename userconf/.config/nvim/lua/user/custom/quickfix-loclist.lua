local U = require("user.utils")

local function window_exists(cb)
  return function()
    return vim.iter(vim.api.nvim_tabpage_list_wins(0)):any(cb)
  end
end

local quickfix_exists = window_exists(U.is_quickfix)

local function quickfix_toggle()
  if quickfix_exists() then
    vim.cmd("cclose")
  else
    vim.cmd("botright copen")
  end
end

vim.keymap.set({ "n", "x" }, "Ö", quickfix_toggle, { desc = "toggle quickfix" })

function _G.qftf(info)
  local items
  local ret = {}
  if info.quickfix == 1 then
    items = vim.fn.getqflist({ id = info.id, items = 0 }).items
  else
    items = vim.fn.getloclist(info.winid, { id = info.id, items = 0 }).items
  end
  local limit = 31
  local fnameFmt1, fnameFmt2 = "%-" .. limit .. "s", "…%." .. (limit - 1) .. "s"
  local validFmt = "%s │%5d:%-3d│%s %s"
  for i = info.start_idx, info.end_idx do
    local e = items[i]
    local fname = ""
    local str
    if e.valid == 1 then
      if e.bufnr > 0 then
        fname = vim.fn.bufname(e.bufnr)
        if fname == "" then
          fname = "[No Name]"
        else
          local result, _ = fname:gsub("^" .. vim.env.HOME, "~")
          fname = result
        end
        if #fname <= limit then
          fname = fnameFmt1:format(fname)
        else
          fname = fnameFmt2:format(fname:sub(1 - limit))
        end
      end
      local lnum = e.lnum > 99999 and -1 or e.lnum
      local col = e.col > 999 and -1 or e.col
      local qtype = e.type == "" and "" or " " .. e.type:sub(1, 1):upper()
      str = validFmt:format(fname, lnum, col, qtype, e.text)
    else
      str = e.text
    end
    table.insert(ret, str)
  end
  return ret
end
