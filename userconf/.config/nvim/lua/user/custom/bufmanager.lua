local F = require("user.functional")
local U = require("user.utils")
local C = require("user.constants")

local config = require("user.config")

local thresholds = { 10, 30, 100, 300, 1000, 3000, 10000 }

local function is_regular_buffer(buf)
  return vim.tbl_contains(C.PATH_BUFTYPES, vim.bo[buf].buftype) or U.is_dummy_buffer(buf)
end

local function delete_buffer(selection)
  local info = vim.fn.getbufinfo(selection.buf)[1]
  if info.changed == 1 then
    vim.notify("can not delete buffer with unsaved changes", vim.log.levels.WARN)
    return false
  end
  local windows = U.list_normal_windows()
  local regular_windows = vim
    .iter(windows)
    :filter(function(win)
      local win_buf = vim.api.nvim_win_get_buf(win)
      return is_regular_buffer(win_buf)
    end)
    :totable()
  local close_wins = vim
    .iter(windows)
    :filter(function(win)
      return vim.api.nvim_win_get_buf(win) == selection.buf
    end)
    :totable()
  local left_buffers = vim
    .iter(U.list_buffers({ mru = true }))
    :filter(function(buf)
      return buf ~= selection.buf
    end)
    :totable()
  if (is_regular_buffer(selection.buf) and #close_wins >= #regular_windows) or #close_wins >= #windows then
    local keep_win = close_wins[1]
    close_wins = F.slice(close_wins, 2)
    if #left_buffers > 0 then
      vim.api.nvim_win_set_buf(keep_win, left_buffers[1])
    else
      local dummy_buf = U.get_dummy_buffer()
      vim.api.nvim_win_set_buf(keep_win, dummy_buf)
    end
  end
  vim.iter(close_wins):each(function(win)
    vim.api.nvim_win_close(win, false)
  end)
  local buftype = vim.bo[selection.buf].buftype
  local ok = pcall(vim.api.nvim_buf_delete, selection.buf, { force = (buftype == "terminal") })
  return ok
end

local function make_items()
  local path_bufnrs = U.list_buffers({ mru = true, buftype = C.FILE_BUFTYPE })
  local terminal_bufnrs = F.reverse(U.list_buffers({ mru = true, unlisted = true, buftype = C.TERMINAL }))
  local all_bufnrs = F.concat(terminal_bufnrs, path_bufnrs)
  local meta = {}
  local items = vim
    .iter(all_bufnrs)
    :map(function(buf)
      local info = vim.fn.getbufinfo(buf)[1]
      local bufname = info.name ~= "" and info.name or "[No Name]"
      local is_path = vim.bo[buf].buftype ~= "terminal"
      local progress = is_path and F.threshold(thresholds, info.changedtick) or nil
      local readonly = vim.bo[buf].readonly and config.icons.Readonly or " "
      local changed = info.changed == 1 and config.icons.Modified or " "
      local mark = vim.api.nvim_buf_get_mark(buf, '"')
      local indicator = string.format("%s %s ", readonly, changed)
      return {
        buf = buf,
        file = bufname,
        name = vim.api.nvim_buf_get_name(buf),
        progress = progress,
        is_path = is_path,
        info = info,
        buftype = vim.bo[buf].buftype,
        filetype = vim.bo[buf].filetype,
        pos = mark[1] ~= 0 and mark or { info.lnum, 0 },
        indicator = indicator,
        text = tostring(buf) .. bufname,
      }
    end)
    :totable()
  meta.bufnr_width = #tostring(F.max(all_bufnrs) or 0)
  local current_buffer = vim.api.nvim_get_current_buf()
  local active_index = F.find_index(all_bufnrs, function(buf)
    return buf == current_buffer
  end)
  meta.default_index = active_index or #terminal_bufnrs + 1
  return meta, items
end

vim.keymap.set({ "n", "x", "t", "i" }, "<F2>", function()
  F.load("snacks", function(snacks)
    local align = snacks.picker.util.align
    local meta, items = make_items()
    snacks.picker.pick({
      source = "bufmanager",
      layout = { cycle = false },
      finder = function(picker, ctx)
        return ctx.filter:filter(items)
      end,
      on_show = function(picker)
        picker.list:set_target(meta.default_index)
        vim.cmd("stopinsert")
      end,
      format = function(item, picker)
        local results = {}
        results[#results + 1] = { align(tostring(item.buf), meta.bufnr_width), "SnacksPickerBufNr" }
        results[#results + 1] = { " " }
        results[#results + 1] = { " " }
        if item.is_path then
          results[#results + 1] = { config.icons.KnownColor, "Progress" .. item.progress }
        else
          results[#results + 1] = { " " }
        end
        results[#results + 1] = { item.indicator, "Orange" }
        results[#results + 1] = { " " }
        vim.list_extend(results, snacks.picker.format.filename(item, picker))
        results[#results + 1] = { " " }
        return results
      end,
      confirm = "jump",
      actions = {
        delete_buffer = function(picker)
          local selected = picker.list:current()
          picker.preview:reset()
          if delete_buffer(selected) then
            items = vim
              .iter(items)
              :filter(function(item)
                return item.buf ~= selected.buf
              end)
              :totable()
            if #items == 0 then
              picker:close()
            else
              picker:refresh()
            end
          end
        end,
      },
      win = {
        input = {
          keys = {
            ["<c-x>"] = { "delete_buffer", mode = { "n", "i" } },
            ["d"] = { "delete_buffer", mode = { "n" } },
            ["x"] = { "delete_buffer", mode = { "n" } },
            ["<F2>"] = { "close", mode = { "n", "i" } },
            ["<Esc>"] = { "close", mode = { "n", "i" } },
            ["s"] = { "edit_split", mode = { "n" } },
            ["v"] = { "edit_vsplit", mode = { "n" } },
          },
        },
        list = {
          keys = {
            ["<c-x>"] = "delete_buffer",
            ["d"] = "delete_buffer",
            ["x"] = "delete_buffer",
            ["s"] = "edit_split",
            ["v"] = "edit_vsplit",
            ["<F2>"] = "close",
            ["<Esc>"] = "close",
          },
        },
        preview = {
          keys = {
            ["<F2>"] = "close",
            ["<Esc>"] = "close",
          },
        },
      },
    })
  end)
end, { desc = "Toggle Buffer Explorer" })
