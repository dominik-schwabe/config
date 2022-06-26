local fn = vim.fn

local F = require("repl.functional")

local M = {}

M.normal_open = "\27[200~"
M.normal_close = "\27[201~"
M.paste_open = ":paste"
M.paste_close = "\04"
M.editor_open = ".editor"
M.cr = "\13"

local extend = require("repl.utils").extend

function M.format_builder(spec)
  return function(lines)
    if #lines ~= 0 then
      if #lines ~= 1 or spec.ignore_single == nil or not spec.ignore_single then
        if spec.concat_start ~= nil then
          lines[1] = spec.concat_start .. lines[1]
        end
        if spec.concat_end ~= nil then
          lines[#lines] = lines[#lines] .. spec.concat_end
        end
        return extend({ spec.append_start, lines, spec.append_end })
      end
    end
    return lines
  end
end

M.normal_format = M.format_builder({
  append_start = M.normal_open,
  append_end = M.normal_close,
})
M.python_format = M.format_builder({
  append_end = "",
  ignore_single = true,
})
M.breaketed_paste_format = M.format_builder({
  concat_start = M.normal_open,
  append_end = M.normal_close,
  ignore_single = true,
})
M.alt_breaketed_paste_format = M.format_builder({
  concat_start = M.normal_open,
  concat_end = M.normal_close,
  ignore_single = true,
})
M.paste_format = M.format_builder({
  append_start = M.paste_open,
  append_end = M.paste_close,
})
M.editor_n_format = M.format_builder({
  -- append_start = M.editor_open .. "\n",
  -- append_end = M.paste_close,
  ignore_single = true,
})

M.repls = {
  clojure = {
    boot = { command = { "boot", "repl" } },
    lein = { command = { "lein", "repl" } },
    clj = { command = { "clj" } },
  },
  cpp = { root = { command = { "root", "-l" } } },
  csh = { csh = { command = { "csh" } }, tcsh = { command = { "tch" } } },
  elixir = { iex = { command = { "iex" } } },
  elm = { elm = { command = { "elm", "repl" } }, elm_legacy = { command = { "elm-repl" } } },
  erlang = { erl = { command = { "erl" } } },
  fennel = { fennel = { command = { "fennel" } } },
  forth = { gforth = { command = { "gforth" } } },
  haskell = {
    stack_intero = { command = { "stack", "ghci", "--with-ghc", "intero" } },
    stack = { command = { "stack", "ghci" } },
    ghci = { command = { "ghci" } },
  },
  hy = { hy = { command = { "hy" } } },
  janet = { janet = { command = { "janet" } } },
  javascript = { node = { command = { "node" }, format = M.editor_n_format } },
  julia = { julia = { command = { "julia" } } },
  lisp = { sbcl = { command = { "sbcl" } }, clisp = { command = { "clisp" } } },
  lua = { lua = { command = { "lua" } } },
  mma = { math = { command = { "math" } } },
  ocaml = { utop = { command = { "utop" } }, ocamltop = { command = { "ocamltop" } } },
  php = { psysh = { command = { "psysh" } }, php = { command = { "php", "-a" } } },
  prolog = { gprolog = { command = { "gprolog" } }, swipl = { command = { "swipl" } } },
  ps1 = { ps1 = { command = { "powershell", "-noexit", "-executionpolicy", "bypass" } } },
  pure = { pure = { command = { "pure" }, format = M.editor_format } },
  python = {
    ipython = { command = { "ipython", "--no-autoindent" }, format = M.breaketed_paste_format },
    ptipython = { command = { "ptipython" }, format = M.breaketed_paste_format },
    ptpython = { command = { "ptpython" }, format = M.breaketed_paste_format },
    python = { command = { "python" }, format = M.python_format },
    python3 = { command = { "python3" }, format = M.python_format },
  },
  r = {
    R = { command = { "R" }, format = M.breaketed_paste_format },
    radian = { command = { "radian" }, format = M.alt_breaketed_paste_format },
  },
  racket = { racket = { command = { "racket" } } },
  ruby = { irb = { command = { "irb" } } },
  sbt = { sbt = { command = { "sbt" }, format = M.paste_format } },
  scala = {
    sbt = { command = { "sbt" }, format = M.paste_format },
    scala = { command = { "scala" }, format = M.paste_format },
  },
  scheme = { guile = { command = { "guile" } }, csi = { command = { "csi" } } },
  sh = { zsh = { command = { "zsh" } }, bash = { command = { "bash" } }, sh = { command = { "sh" } } },
  stata = { stata = { command = { "stata", "-q" } } },
  tcl = { tclsh = { command = { "tclsh" } } },
  typescript = { ts = { command = { "ts-node" }, format = M.editor_n_format } },
  zsh = { zsh = { command = { "zsh" } } },
}

local function create_message(list, suffix)
  if #list ~= 0 then
    return "repls "
      .. table.concat(
        F.map(list, function(str)
          return "'" .. str .. "'"
        end),
        " "
      )
      .. suffix
  end
  return nil
end

function M.find(ft, preferred)
  local wanted_repls = preferred[ft]
  local available_repls = M.repls[ft]
  local messages = {}

  if available_repls == nil or next(available_repls) == nil then
    messages[#messages + 1] = "no repl configured for filetype '" .. ft .. "'"
    return nil, messages
  end
  if wanted_repls == nil then
    wanted_repls = F.keys(available_repls)
    table.sort(wanted_repls)
  end
  local repl_to_use = nil
  local unavailable_repls = {}
  local uninstalled_repls = {}
  F.foreach(wanted_repls, function(key)
    local repl = available_repls[key]
    if repl == nil then
      unavailable_repls[#unavailable_repls + 1] = key
    else
      if repl_to_use == nil then
        if fn.executable(repl.command[1]) == 1 then
          repl_to_use = key
        else
          uninstalled_repls[#uninstalled_repls + 1] = key
        end
      end
    end
  end)
  messages[#messages + 1] = create_message(unavailable_repls, " not configured")
  messages[#messages + 1] = create_message(uninstalled_repls, " not executable")
  return repl_to_use, messages
end

return M
