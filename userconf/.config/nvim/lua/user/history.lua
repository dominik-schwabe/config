local preview = require("user.preview")

local F = require("user.functional")
local U = require("user.utils")

local function entries_are_same(entry1, entry2)
  return entry1.regtype == entry2.regtype and U.lines_are_same(entry1.contents, entry2.contents)
end

local Entry = {}
Entry.__index = Entry

function Entry:new(obj)
  return setmetatable(obj, self)
end

function Entry:text(compact)
  local text = table.concat(self.contents, "\n")
  if compact then
    text = text:gsub("[\n\t ]+", " ")
    text = U.remove_leading_space(text)
  end
  return text
end

function Entry:markdown(compact)
  local contents = self.contents
  if compact then
    contents = U.fix_indent(contents)
  end
  return F.concat({ "```" .. (self.filetype or "") }, contents, { "```" })
end

function Entry:markdown_string(compact)
  return table.concat(self:markdown(compact), "\n")
end

function Entry:first_line()
  return U.remove_leading_space(U.remove_empty_lines(self.contents)[1] or "")
end

local History = {}
History.__index = History

function History:new(obj)
  obj.entries = {}
  obj.pos = 0
  obj.size = obj.size or 50
  return setmetatable(obj, self)
end

function History:current(pos)
  return self.entries[pos == nil and self.pos or pos]
end

function History:is_present(entry)
  return self.pos ~= 0 and entries_are_same(entry, self.entries[self.pos])
end

function History:prune()
  local entries = self.entries
  local pos = self.pos
  if pos ~= #entries then
    local element = entries[pos]
    while pos < #entries do
      entries[pos] = entries[pos + 1]
      pos = pos + 1
    end
    entries[pos] = element
  end
  if #entries >= self.size then
    entries = F.slice(entries, #entries - self.size + 2)
  end
  self.entries = entries
  self.pos = pos
end

function History:add(entry)
  entry = Entry:new(entry)
  if not (self.filter and self.filter(entry)) and not self:is_present(entry) then
    self:prune()
    self.entries[#self.entries + 1] = entry
    self.pos = #self.entries
  end
end

function History:get_register_name()
  return type(self.register) == "function" and self.register() or self.register
end

function History:read_register()
  local register = self:get_register_name()
  return {
    regtype = vim.fn.getregtype(register),
    contents = vim.fn.getreg(register, 1, true),
  }
end

function History:write_register()
  local entry = self:current()
  local register = self:get_register_name()
  vim.fn.setreg(register, entry.contents, entry.regtype)
  if self.write_callback then
    self.write_callback(register)
  end
end

function History:add_current()
  self:add(self:read_register())
end

function History:select_by_index(index)
  index = U.clip(index, 1, #self.entries)
  local entry = self.entries[index]
  table.remove(self.entries, index)
  self.pos = #self.entries
  self:add_current()
  self:add(entry)
  self:write_register()
end

function History:select_by_direction(direction)
  self.pos = U.clip(self.pos + direction, 1, #self.entries)
  self:write_register()
end

function History:preview(entry)
  entry = entry or self:current()
  if not entry then
    self:notify_empty()
    return
  end
  local contents = entry.contents
  if self.preview_preprocess then
    contents = self.preview_preprocess(contents)
  end
  preview.show(contents, {
    title = self.name .. " entry " .. self.pos .. "/" .. #self.entries,
    filetype = entry.filetype,
  })
end

function History:notify_empty()
  vim.notify(self.name .. " history is empty")
end

function History:cycle(direction)
  self:add_current()
  local current_entry = self:current()
  if not current_entry then
    self:notify_empty()
    return
  end
  if not entries_are_same(self:read_register(), current_entry) then
    direction = 0
  end
  self:select_by_direction(direction)
  self:preview()
end

function History:select(index)
  self:select_by_index(#self.entries - index + 1)
end

function History:top(num)
  return F.slice(self.entries, #self.entries - num)
end

function History:to_telescope()
  local results = {}
  for index, entry in ipairs(self.entries) do
    index = #self.entries - index + 1
    entry = F.copy(entry)
    entry.index = index
    results[index] = entry
  end
  return results
end

local function previewer()
  return require("telescope.previewers").new_buffer_previewer({
    define_preview = function(self, entry)
      vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "nofile")
      vim.lsp.util.stylize_markdown(self.state.bufnr, entry.value:markdown())
    end,
  })
end

function History:make_telescope_extension()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local entry_display = require("telescope.pickers.entry_display")
  local conf = require("telescope.config").values

  local history = self

  local function attach_mappings(_, map)
    local function accept(bufnr)
      actions.close(bufnr)
      history:select(action_state.get_selected_entry().index)
    end
    map("i", "<CR>", accept)
    map("n", "<CR>", accept)

    return true
  end

  local function gen_from_history(opts)
    local displayer = entry_display.create({
      separator = " ",
      items = {
        { width = #tostring(opts.history_length) },
        { remaining = true },
      },
    })

    local make_display = function(entry)
      return displayer({
        { entry.value.index, "TelescopeResultsNumber" },
        entry.content,
      })
    end

    return function(entry)
      local text = U.remove_leading_space(entry:text())
      return {
        value = entry,
        ordinal = text,
        content = text,
        display = make_display,
      }
    end
  end

  local function entry_point(opts)
    opts = opts or {}
    local results = history:to_telescope()
    opts.history_length = #results
    pickers
      .new(opts, {
        prompt_title = self.name .. " history",
        finder = finders.new_table({
          results = results,
          entry_maker = gen_from_history(opts),
        }),
        attach_mappings = attach_mappings,
        previewer = previewer(),
        sorter = conf.generic_sorter(opts),
      })
      :find()
  end
  return require("telescope").register_extension({
    exports = {
      [self.name:lower() .. "_history"] = entry_point,
    },
  })
end

function History:make_completion_source()
  local history = self

  local Source = {}
  Source.__index = Source
  function Source:new()
    return setmetatable({}, self)
  end

  function Source:complete(request, callback)
    local input = request.context.cursor_before_line:sub(request.offset - 1)
    local items = F.map(history:top(10), function(entry)
      return {
        label = entry:text(true),
        documentation = {
          kind = "markdown",
          value = entry:markdown_string(true),
        },
        textEdit = {
          newText = entry:text(),
          range = {
            start = {
              line = request.context.cursor.row,
              character = request.context.cursor.col - #input,
            },
            ["end"] = {
              line = request.context.cursor.row,
              character = request.context.cursor.col - #input,
            },
          },
        },
      }
    end)
    callback(items)
  end

  return Source
end

return History
