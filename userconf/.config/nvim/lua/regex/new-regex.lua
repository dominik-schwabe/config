local fn = vim.fn

local function replace_termcodes(str)
  return vim.api.nvim_replace_termcodes(str, false, true, true)
end

local meta_chars = [[$*.[\]^~]]
local ch_with_backslash = 0
local ch_posix_charclass = 1
local ch_brackets = 2
local ch_braces = 3
local ch_parentheses_option = 4 local ch_parentheses = 5
local divider = "::"
local mark_left = replace_termcodes([[<Esc>]]) .. divider .. replace_termcodes([[<C-f>]])
local mark_right = replace_termcodes([[<C-l>]]) .. divider .. replace_termcodes([[<Esc>]])
local re_unescaped = [[\%(\\\)\@<!\%(\\\\\)*\zs]]
local re_escaped = [[\%(\\\)\@<!\%(\\\\\)*\zs\\]]
local mark_complements = mark_left .. "--" .. mark_right
local multiline = 0
local ignorecase = 0
local extended_spaces = 0
local extended_complements = 0
local extended_dots = 0
local countermeasure = 1
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
  return match >= 0 and match or nil
end

local function ExchangeReplaceSpecials(replacement, sort)
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

local function ReplaceRemainFactorWithVimRegexFactor(halfway)
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

local function ReplaceAsStr(str, search, replacement)
  local oldstr = str
  local newstr = ""
  local i = fn.stridx(oldstr, search)
  newstr = newstr .. fn.strpart(oldstr, 0, i) .. replacement
  oldstr = fn.strpart(oldstr, i + #search)
  if #oldstr > 0 then
    newstr = newstr .. oldstr
  end
  return newstr
end

local function SetModifiers(mods)
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

local function ExpandAtomsInBrackets(bracket)
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
      local chr = fct:sub(2, 2)
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
    searchstart = mtop + #mstr
    mtop = fn.match(bracket, re_mark, searchstart)
  end
  if (complement == 1) and (has_newline == 0) then
    bracket = mark_complements .. bracket
  end
  return bracket
end

local function Push(fct, kind)
  if (kind == ch_with_backslash) and (match_case(fct, [[^\\x\x\{1,2}$]])) then -- \x41
    local code = tonumber("0x" .. fn.matchstr(fct, [[\x\{1,2}$]]))
    if code ~= 0x0a and code ~= 0 and code ~= 0x08 then
      fct = fn.nr2char(code)
      if fn.stridx(meta_chars, fct) ~= -1 then
        fct = [[\]] .. fct
      end
    end
  elseif kind == ch_with_backslash then -- \.  \_x
    local chr = fct:sub(2, 2)
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
    fct = fn.strpart(fct, 0, #fct - 1)
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
  stack[#stack + 1] = fct
end

local function Pop()
  if #stack <= 0 then
    return ""
  end
  local top = stack[#stack]
  stack[#stack] = nil
  return top
end

local function ReplaceExtendedRegexFactorWithNumberFactor(extendedregex)
  local halfway = extendedregex
  local id_num = 0
  for i, value in ipairs(re_factor) do
    i = i - 1
    local regex = [[\C]] .. value
    local mtop = fn.match(halfway, regex)
    while mtop >= 0 do
      local factor = fn.matchstr(halfway, regex)
      local pre_match = fn.strpart(halfway, 0, mtop)
      local post_match = fn.strpart(halfway, mtop + #factor)
      halfway = pre_match .. mark_left .. id_num .. mark_right .. post_match
      Push(factor, i)
      id_num = id_num + 1
      mtop = fn.match(halfway, regex)
    end
  end
  return halfway
end

local function ReplaceNumberFactorWithVimRegexFactor(halfway)
  local vimregex = halfway

  local i = #stack
  while i > 0 do
    i = i - 1
    vimregex = ReplaceAsStr(vimregex, mark_left .. i .. mark_right, Pop())
  end
  stack = {}

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
  extended_spaces = 0
  extended_complements = 0
  extended_dots = 0
  multiline = 0
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
