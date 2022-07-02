local fn = vim.fn

local F = require("regex.functional")

local function replace_termcodes(str)
  return vim.api.nvim_replace_termcodes(str, false, true, true)
end

local meta_chars = [[$*.[\]^~]]
local ch_with_backslash = 0
local ch_posix_charclass = 1
local ch_brackets = 2
local ch_braces = 3
local ch_parentheses_option = 4
local ch_parentheses = 5
local mark_left = replace_termcodes([[<Esc>]]) .. fn.strftime("%X") .. ":" .. fn.strftime("%d") .. replace_termcodes([[<C-f>]])
local mark_right = replace_termcodes([[<C-l>]]) .. fn.strftime("%X") .. ":" .. fn.strftime("%d") .. replace_termcodes([[<Esc>]])
local re_unescaped = [[\%(\\\)\@<!\%(\\\\\)*\zs]]
local re_escaped = [[\%(\\\)\@<!\%(\\\\\)*\zs\\]]
local mark_complements = mark_left .. "cOmPLemEnTs" .. mark_right
local multiline = 0
local ignorecase = 0
local extended_spaces = 0
local extended_complements = 0
local extended_dots = 0
local countermeasure = 1
local stack_size = 0
local stack = {}

local re_factor = {
  [=[\\\%([^x_]\|x\x\{0,2}\|_[.$^]\=\)]=],
  [=[\[:\%(alnum\|alpha\|blank\|cntrl\|digit\|graph\|lower\|print\|punct\|space\|upper\|xdigit\|return\|tab\|escape\|backspace\):\]]=],
  [=[\[\%([^^][^]]*\|\^.[^]]*\)\]]=],
  [=[{[0-9,]\+}?\=]=],
  [=[(?[iImM]\{1,2})]=],
  [=[(\(?:\|?=\|?!\|?<=\|?<!\|?>\|?[-#ixm]\)\=[^()]*)]=],
}

local function match_case(str, pattern)
  local match = fn.match(str, [[\C]] .. pattern)
  if match < 0 then
    match = nil
  end
  return match
end

local function match_ignorecase(str, pattern)
  local match = fn.match(str, [[\C]] .. pattern)
  if match < 0 then
    match = nil
  end
  return match
end

function ExchangeReplaceSpecials(replacement, sort)
  if not match_case(replacement, [=[[&~]\|\\[rnx]]=]) or match_case(replacement, [[^\\=]]) then
    return replacement
  end
  if (sort % 2) == 1 then
    replacement = fn.substitute(replacement, [[\C]] .. re_escaped .. "r", [[\\R]], "g")
    replacement = fn.substitute(replacement, [[\C]] .. re_escaped .. "n", [[\\r]], "g")
    replacement = fn.substitute(replacement, [[\C]] .. re_escaped .. "R", [[\\n]], "g")
  end
  if sort >= 2 then
    replacement = fn.substitute(replacement, [[\C]] .. re_escaped .. "&", [[\\R]], "g")
    replacement = fn.substitute(replacement, [[\C]] .. re_escaped .. [[\~]], [[\\N]], "g")
    replacement = fn.substitute(replacement, [[\C]] .. re_unescaped .. "[&~]", [[\\&]], "g")
    replacement = fn.substitute(replacement, [[\C]] .. re_escaped .. "R", [[\&]], "g")
    replacement = fn.substitute(replacement, [[\C]] .. re_escaped .. "N", [[\~]], "g")
  end
  return replacement
end

function ReplaceAsStr(str, search, replacement, ...)
  local args = { ... }
  local gsub = #args
  if gsub > 0 then
    gsub = match_ignorecase(args[1], "g") and 1 or 0
  end
  local oldstr = str
  local newstr = ""
  local len = fn.strlen(search)
  local i = fn.stridx(oldstr, search)
  while i >= 0 do
    newstr = newstr .. fn.strpart(oldstr, 0, i) .. replacement
    oldstr = fn.strpart(oldstr, i + len)
    if gsub == 0 then
      break
    end
    i = fn.stridx(oldstr, search)
  end
  if fn.strlen(oldstr) ~= 0 then
    newstr = newstr .. oldstr
  end
  return newstr
end

function SetModifiers(mods)
  if ignorecase == 0 then
    if mods:match("i") then
      ignorecase = 1
    elseif mods:match("I") then
      ignorecase = 2
    end
  end
  if multiline == 0 then
    if mods:match("[mM]") then
      extended_spaces = 1
      extended_complements = 1
      if mods:match("M") then
        multiline = 1
      else
        extended_dots = 1
        multiline = 2
      end
    end
  end

  if mods:match("S") then
    extended_spaces = 1
  end
  if mods:match("C") then
    extended_complements = 1
  end
  if mods:match("D") then
    extended_dots = 1
  end
end

function ExpandAtomsInBrackets(bracket)
  local re_mark = mark_left .. [[\d\+]] .. mark_right
  local re_snum = mark_left .. [[\(\d\+\)]] .. mark_right
  local has_newline = 0
  local complement = match_case(bracket, [[^\[^]]) == nil and 0 or 1

  local searchstart = 0
  local mtop = fn.match(bracket, re_mark, searchstart)
  while mtop >= 0 do
    local mstr = fn.matchstr(bracket, re_mark, searchstart)
    local snum = tonumber(fn.substitute(mstr, re_snum, [[\1]], ""))
    local fct = stack[snum + 1]
    -- exclude, \e=0x1b, \b=0x08, \r=0x0d, \t=0x09
    if match_case(fct, [[^\\[adfhlosuwx]$]]) then
      local chr = fct:sub(2,2)
      if chr == "a" then
        fct = "A-Za-z"
      elseif chr == "d" then
        fct = "0-9"
      elseif chr == "f" then
        fct = fn.nr2char(0x0c)
        fct = "\x0c"
      elseif chr == "h" then
        fct = "A-Za-z_"
      elseif chr == "l" then
        fct = "a-z"
      elseif chr == "o" then
        fct = "0-7"
      elseif chr == "s" then
        if extended_spaces == 1 then
          if (countermeasure == 1) and (complement == 1) then
            fct = " \\t\\r\x0c"
          else
            fct = " \\t\\r\\n\x0c"
          end
          has_newline = 1
        else
          fct = [[ \t]]
        end
      elseif chr == "u" then
        fct = "A-Z"
      elseif chr == "w" then
        fct = "0-9A-Za-z_"
      elseif chr == "x" then
        fct = "0-9A-Fa-f"
      end
      stack[snum + 1] = fct
    else
      if fct == [[\n]] then
        -- If there is only "\n" of inside of the brackets.
        -- It becomes the same as "\_.".
        has_newline = 1
      elseif fct == "-" then
        -- '-' converted from \xnn
        -- If there is '-' in the beginning of the brackets and the end.
        -- Unnecessary '\' is stuck.
        stack[snum + 1] = [[\-]]
      elseif fct == [[\[]] then
        -- '\[' converted from \xnn
        stack[snum + 1] = "["
      end
    end
    searchstart = mtop + fn.strlen(mstr)
    mtop = fn.match(bracket, re_mark, searchstart)
  end
  if (complement == 1) and (has_newline == 0) then
    bracket = mark_complements .. bracket
  end
  return bracket
end

function Push(fct, kind)
  if (kind == ch_with_backslash) and (match_case(fct, [[^\\x\x\{1,2}$]])) then -- \x41
    local code = tonumber("0x" .. fn.matchstr(fct, [[\x\{1,2}$]]))
    if code ~= 0x0a and code ~= 0 and code ~= 0x08 then
      fct = fn.nr2char(code)
      if fn.stridx(meta_chars, fct) ~= -1 then
        fct = [[\]] .. fct
      end
    end
  elseif kind == ch_with_backslash then -- \.  \_x
    local chr = fct:sub(2,2)
    if match_case(chr, "[+?{}|()=]") then
      fct = chr
    else
      if chr == "v" then
        fct = fn.nr2char(0x0b)
      elseif chr == "V" then
        fct = "V"
        -- [IiMm]
      end
    end
  elseif kind == ch_posix_charclass then -- [:alpha:] pass through
  elseif kind == ch_brackets then -- [ ]
    fct = ExpandAtomsInBrackets(fct)
  elseif kind == ch_braces then -- { }
    fct = [[\]] .. fct -- minimal match, not greedy
    if match_case(fct, "?$") then
      if match_case(fct, [[\d\+,\d\+]]) then
        fct = fn.substitute(fct, [[{\(\d\+\),\(\d\+\)}?]], [[{-\1,\2}]], "")
      elseif match_case(fct, ",}") then
        fct = fn.substitute(fct, [[{\(\d\+\),}?]], [[{-\1,}]], "")
      elseif match_case(fct, "{,") then
        fct = fn.substitute(fct, [[{,\(\d\+\)}?]], [[{-,\1}]], "")
      else
        fct = fn.strpart(fct, 1)
      end
    end
  elseif kind == ch_parentheses_option then -- ( )
    SetModifiers(fct)
    fct = ""
  elseif (kind == ch_parentheses) and match_case(fct, "(?[-#ixm]") then -- ( )
    if match_case(fct, [[(?-\=[ixm]\{1,3})]]) or match_case(fct, "(?#") then
      fct = ""
    else
      fct = fn.substitute(fct, [[(?-\=[ixm]\{1,3}:\([^()]*\))]], [[\1]], "")
      fct = ReplaceRemainFactorWithVimRegexFactor(fct)
    end
  elseif kind == ch_parentheses then -- ( )
    local kakko = fn.matchstr(fct, [[(\(?:\|?=\|?!\|?<=\|?<!\|?>\)\=]])
    fct = fn.substitute(fct, [[(\(?:\|?=\|?!\|?<=\|?<!\|?>\)\=]], "", "")
    fct = fn.strpart(fct, 0, fn.strlen(fct) - 1)
    fct = ReplaceRemainFactorWithVimRegexFactor(fct)
    if kakko == "(" then
      fct = [[\(]] .. fct .. [[\)]]
    elseif kakko == "(?:" then
      fct = [[\%(]] .. fct .. [[\)]]
    elseif kakko == "(?=" then
      fct = [[\%(]] .. fct .. [[\)\@=]]
    elseif kakko == "(?!" then
      fct = [[\%(]] .. fct .. [[\)\@!]]
    elseif kakko == "(?<=" then
      fct = [[\%(]] .. fct .. [[\)\@<=]]
    elseif kakko == "(?<!" then
      fct = [[\%(]] .. fct .. [[\)\@<!]]
    elseif kakko == "(?>" then
      fct = [[\%(]] .. fct .. [[\)\@>]]
    else
      fct = ":BUG:"
    end
  end
  stack[stack_size+1] = fct
  stack_size = stack_size + 1
end

function Pop()
if stack_size <= 0 then return "" end
  stack_size = stack_size - 1
  return stack[stack_size+1]
end

function UnletStack()
  stack = {}
  stack_size = 0
end

function ReplaceExtendedRegexFactorWithNumberFactor(extendedregex)
  local halfway = extendedregex
  stack_size = 0
  local id_num = 0
  for i, value in ipairs(re_factor) do
    i = i - 1
    local regex = [[\C]] .. value
    local mtop = fn.match(halfway, regex)
    while mtop >= 0 do
      local factor = fn.matchstr(halfway, regex)
      local pre_match = fn.strpart(halfway, 0, mtop)
      local post_match = fn.strpart(halfway, mtop + fn.strlen(factor))
      halfway = pre_match .. mark_left .. id_num .. mark_right .. post_match
      Push(factor, i)
      id_num = id_num + 1
      mtop = fn.match(halfway, regex)
    end
  end
  return halfway
end

function ReplaceRemainFactorWithVimRegexFactor(halfway)
  halfway = halfway
  halfway = fn.substitute(halfway, "+?", [[\\{-1,}]], "g")
  halfway = fn.substitute(halfway, [[\*?]], [[\\{-}]], "g")
  halfway = fn.substitute(halfway, "??", [[\\{-,1}]], "g")
  halfway = fn.substitute(halfway, "+", [[\\+]], "g")
  halfway = fn.substitute(halfway, "?", [[\\=]], "g")
  halfway = fn.substitute(halfway, "|", [[\\|]], "g")
  halfway = fn.substitute(halfway, [[\~]], [[\\&]], "g")
  if extended_dots == 1 then
    halfway = fn.substitute(halfway, [[\.]], [[\\_.]], "g")
  end

  return halfway
end

function ReplaceNumberFactorWithVimRegexFactor(halfway)
  local vimregex = halfway

  local i = stack_size
  while i > 0 do
    i = i - 1

    local factor = Pop()
    local str_mark = mark_left .. i .. mark_right
    vimregex = ReplaceAsStr(vimregex, str_mark, factor)
  end
  -- Debug:
  UnletStack()

  if fn.stridx(vimregex, mark_complements) ~= -1 then
    if extended_complements == 1 then
      -- there isn't \_ before [^...].
      -- [^...] doesn't contain \n.
      local re = [[\C\%(\%(\\\)\@<!\(\\\\\)*\\_\)\@<!\zs]] .. mark_complements
      vimregex = fn.substitute(vimregex, re, [[\\_]], "g")
    end
    vimregex = fn.substitute(vimregex, [[\C]] .. mark_complements, "", "g")
  end
  if extended_complements == 1 then
    local re = [[\C]] .. re_escaped .. [[\([ADHLOUWX]\)]]
    vimregex = fn.substitute(vimregex, re, [[\\_\1]], "g")
  end
  if extended_spaces == 1 then
    --    | atom | normal   | extended spaces
    --    | \s   | [ \t]    | [ \t\r\n\f]
    --    | \S   | [^ \t]   | [^ \t\r\n\f]
    --    | \_s  | \_[ \t]  | [ \t\r\n\f]
    --    | \_S  | \_[^ \t] | [^ \t\r\n\f]       *
    local ff = fn.nr2char(0x0c)
    local re = [[\C]] .. re_escaped .. [[_\=s]]
    vimregex = fn.substitute(vimregex, re, "[" .. [[ \\t\\r\\n]] .. ff .. "]", "g")
    re = [[\C]] .. re_escaped .. [[_\=S]]
    if countermeasure == 1 then
      vimregex = fn.substitute(vimregex, re, "[" .. [[^ \\t\\r]] .. ff .. "]", "g")
    else
      vimregex = fn.substitute(vimregex, re, "[" .. [[^ \\t\\r\\n]] .. ff .. "]", "g")
    end
  end

  if ignorecase > 0 then
    local tmp = ignorecase == 1 and [[\c]] or [[\C]]
    vimregex = tmp .. vimregex
  end
  return vimregex
end

local function ExtendedRegex2VimRegex(extendedregex, modifiers)
  ignorecase = 0
  multiline = 0
  extended_spaces = 0
  extended_complements = 0
  extended_dots = 0
  if modifiers then
    local match = modifiers:match("R[0-3]")
    if match then
      return ExchangeReplaceSpecials(extendedregex, tonumber(match:sub(2)))
    end
    SetModifiers(modifiers)
  end
  if #extendedregex == 0 then
    return ""
  end
  local eregex = extendedregex
  local mods = fn.matchstr(eregex, [[\C]] .. re_escaped .. "[Mm]")
  mods = mods .. fn.matchstr(eregex, [[\C]] .. re_escaped .. "[Cc]")
  if mods ~= "" then
    mods = mods:gsub("C", "I")
    mods = mods:gsub("c", "i")
    SetModifiers(mods)
    local re = [[\C]] .. re_escaped .. "[MmCc]"
    eregex = fn.substitute(eregex, re, "", "g")
  end

  local halfway = ReplaceExtendedRegexFactorWithNumberFactor(eregex)
  halfway = ReplaceRemainFactorWithVimRegexFactor(halfway)
  local vimregex = ReplaceNumberFactorWithVimRegexFactor(halfway)
  return vimregex
end

local M = {}

function M.E2v(extendedregex, modifiers)
  return ExtendedRegex2VimRegex(extendedregex, modifiers)
end

return M

-- local eregex_replacement = 0
-- local eglobal_working = 0
-- local str_modifiers = "iISCDMm"
-- local bakregex = ""
-- local invert = 0

-- function Ematch(...)
--   local args = { ... }
--   local ccount = args[1]
--   local str = fn.strlen(args[2]) <= 1 and (args[2] .. vim.fn.getreg("@/")) or args[2]
--   local delim = str:sub(1, 1)

--   if delim ~= [[/]] and delim ~= "?" then
--     error("The delimiter '" .. delim .. "' isn't available,  use '/' .")
--   end

--   local rxp = [[^delim\(\%([^delim\\]\|\\.\)*\)\(delim.*\)\=$]]
--   rxp = rxp:gsub("delim", delim)

--   local regex = fn.substitute(str, rxp, [[\1]], "")
--   local offset = fn.substitute(str, rxp, [[\2]], "")

--   local modifiers = ""
--   if match_case(offset, "[" .. str_modifiers .. "]") then
--     modifiers = fn.substitute(offset, [[\C]] .. "[^" .. str_modifiers .. "]" .. [[\+]], "", "g")
--     offset = fn.substitute(offset, [[\C]] .. "[" .. str_modifiers .. "]" .. [[\+]], "", "g")
--   end

--   if vim.g.eregex_force_case == 1 then
--     if fn.match(modifiers, "i") == -1 and fn.match(modifiers, "I") == -1 then
--       modifiers = modifiers .. "I"
--     end
--   end

--   regex = ExtendedRegex2VimRegex(regex, modifiers)
--   regex = EscapeAndUnescape(regex, delim)

--   if offset == "" then
--     offset = delim
--   end

--   local cmd = "normal! " .. ccount .. delim .. regex .. offset .. replace_termcodes([[<CR>]])
--   vim.v.errmsg = ""
--   vim.opt.hlsearch = false
--   vim.cmd(cmd)
--   if not match_case(vim.v.errmsg, [[^E\d\+:]]) or match_case(vim.v.errmsg, "^E486:") then
--     if bakregex ~= "" then
--       fn.setreg("@/", bakregex)
--     end
--   end
--   if vim.v.errmsg == "" then
--     vim.cmd("redraw!")
--     if vim.opt.foldenable and F.contains(vim.opt.foldopen:get(), "search") then
--       vim.cmd("normal!zv")
--     end
--   else
--     error(vim.v.errmsg)
--   end

--   if delim == "?" then
--     return 0
--   else
--     return 1
--   end
-- end

-- function Esubstitute(...)
--   local args = { ... }
--   local str = args[1]
--   if fn.strlen(str) <= 1 then
--     return
--   end
--   local delim = GetDelim(str:sub(1, 1))
--   if delim == "" then
--     return
--   end

--   local rxp = [[^delim\([^delim\\]*\%(\\.[^delim\\]*\)*\)delim\([^delim\\]*\%(\\.[^delim\\]*\)*\)\(delim.*\)\=$]]
--   rxp = fn.substitute(rxp, "delim", delim, "g")
--   if not match_case(str, rxp) then
--     if eglobal_working == 0 then
--       error("Invalid arguments S" .. str)
--     end
--     return
--   end
--   local regex = fn.substitute(str, rxp, [[\1]], "")
--   local replacement = fn.substitute(str, rxp, [[\2]], "")
--   local options = fn.substitute(str, rxp, [[\3]], "")
--   local modifiers = ""
--   if match_case(options, "[" .. str_modifiers .. "]") then
--     modifiers = fn.substitute(options, [[\C]] .. "[^" .. str_modifiers .. "]" .. [[\+]], "", "g")
--     options = fn.substitute(options, [[\C]] .. "[SCDmM]", "", "g")
--   end

--   if vim.g.eregex_force_case == 1 then
--     if fn.match(modifiers, "i") == -1 and fn.match(modifiers, "I") == -1 then
--       modifiers = modifiers .. "I"
--     end
--   end

--   regex = ExtendedRegex2VimRegex(regex, modifiers)
--   regex = EscapeAndUnescape(regex, delim)

--   if (eregex_replacement > 0) and (fn.strlen(replacement) > 1) then
--     replacement = ExchangeReplaceSpecials(replacement, eregex_replacement)
--   end
--   if options == "" then
--     options = delim
--   end

--   local cmd = args["firstline"] .. "," .. args["lastline"] .. "s" .. delim .. regex .. delim .. replacement .. options

--   -- Evaluater:
--   vim.g.eregex_evaluater_how_exe = eglobal_working
--   if vim.g.eregex_evaluater_how_exe == 0 then
--     vim.v.statusmsg = ""
--     vim.v.errmsg = ""
--   end
--   local confirmoption = match_case(options, "c")
--   if confirmoption == 1 then
--     vim.g.eregex_evaluater_how_exe = 1
--   end
--   vim.g.eregex_evaluater_cmd = cmd
--   -- runtime plugin/eregex_e.vim
--   if vim.g.eregex_evaluater_how_exe == 0 or confirmoption == 1 then
--     vim.g.eregex_evaluater_cmd = nil
--     if bakregex ~= "" then
--       fn.setreg("@/", bakregex)
--     end

--     if confirmoption == 0 then
--       if vim.v.errmsg == "" then
--         if vim.v.statusmsg ~= "" then
--           error(vim.v.statusmsg)
--         end
--       else
--         error(vim.v.errmsg)
--       end
--     end
--   end
-- end

-- function Eglobal(bang, ...)
--   local args = { ... }
--   if fn.strlen(args[1]) <= 1 then
--     return
--   end
--   local str = args[1]
--   local delim = GetDelim(str:sub(1, 1))
--   if delim == "" then
--     return
--   end

--   local re_pattern = fn.substitute([[[^delim\\]*\%(\\.[^delim\\]*\)*]], "delim", delim, "g")
--   local re_offset = [[\%([-+0-9]\d*\|\.[-+]\=\d*\)]]
--   local re_sep = "[,;]"
--   local re_command = "[^,;].*"
--   local re_command_less = [[\_$]]
--   local re_end = [[\%(]] .. re_sep .. [[\|]] .. re_command .. [[\|]] .. re_command_less .. [[\)]]

--   local toprxp = {
--     "^" .. delim .. [[\(]] .. re_pattern .. [[\)\(]] .. delim .. re_offset .. re_sep .. [[\)]],
--     "^" .. delim .. [[\(]] .. re_pattern .. [[\)\(]] .. delim .. re_sep .. [[\)]],
--     "^",
--   }

--   local endrxp = {
--     delim .. [[\(]] .. re_pattern .. [[\)\(]] .. delim .. re_offset .. re_end .. [[\)]],
--     delim .. [[\(]] .. re_pattern .. [[\)\(]] .. delim .. re_end .. [[\)]],
--     delim .. [[\(]] .. re_pattern .. [[\)]] .. re_command_less,
--   }

--   local mtop = -1
--   local j = 1
--   local i
--   local regexp
--   while j <= 3 do
--     i = 1
--     while i <= 3 do
--       regexp = toprxp[j] .. endrxp[i]
--       mtop = fn.match(str, regexp)
--       if mtop >= 0 then
--         break
--       end
--       i = i + 1
--     end
--     if mtop >= 0 then
--       break
--     end
--     j = j + 1
--   end
--   if mtop < 0 then
--     return
--   end

--   if bang == "!" then
--     invert = 1
--   end
--   local cmd = invert == 0 and "g" or "v"
--   invert = 0
--   cmd = args["firstline"] .. "," .. args["lastline"] .. cmd
--   local globalcmd = ""
--   if j == 3 then
--     local pattern1 = fn.substitute(str, regexp, [[\1]], "")
--     local strright = delim
--     if i < 2 then
--       strright = fn.substitute(str, regexp, [[\2]], "")
--     end

--     pattern1 = ExtendedRegex2VimRegex(pattern1)
--     pattern1 = EscapeAndUnescape(pattern1, delim)
--     globalcmd = cmd .. delim .. pattern1 .. strright
--   else
--     local pattern1 = fn.substitute(str, regexp, [[\1]], "")
--     local strmid = fn.substitute(str, regexp, [[\2]], "")
--     local pattern2 = fn.substitute(str, regexp, [[\3]], "")
--     local strright = delim
--     if i < 2 then
--       strright = fn.substitute(str, regexp, [[\4]], "")
--     end

--     pattern1 = ExtendedRegex2VimRegex(pattern1)
--     pattern2 = ExtendedRegex2VimRegex(pattern2)
--     pattern1 = EscapeAndUnescape(pattern1, delim)
--     pattern2 = EscapeAndUnescape(pattern2, delim)

--     globalcmd = cmd .. delim .. pattern1 .. strmid .. delim .. pattern2 .. strright
--   end

--   -- Evaluater:
--   eglobal_working = 1
--   vim.g.eregex_evaluater_how_exe = 2
--   vim.g.eregex_evaluater_cmd = globalcmd

--   -- runtime plugin/eregex_e.vim
--   eglobal_working = 0
--   vim.g.eregex_evaluater_how_exe = 0
--   vim.g.eregex_evaluater_cmd = nil
-- end

-- function Evglobal(...)
--   local args = { ... }
--   invert = 1
--   local cmd = args["firstline"] .. "," .. args["lastline"] .. "G" .. args[1]
--   vim.cmd(cmd)
-- end

-- function GetDelim(str)
--   local valid = "[/@#]"
--   local delim = str:sub(1, 1)
--   if match_case(delim, valid) then
--     return delim
--   end
--   error("The delimiter '" .. delim .. "' isn't available,  use " .. valid)
--   return ""
-- end

-- function EscapeAndUnescape(vimregex, delim)
--   bakregex = vimregex
--   if delim == "@" then
--     return vimregex
--   end

--   if match_case(bakregex, re_escaped .. delim) then
--     -- \/ or \# exists
--     bakregex = fn.substitute(vimregex, re_escaped .. delim, delim, "g")
--   end
--   if match_case(vimregex, re_unescaped .. delim) then
--     -- / or # exists
--     vimregex = fn.substitute(vimregex, re_unescaped .. delim, [[\\]] .. delim, "g")
--   end

--   return vimregex
-- end
