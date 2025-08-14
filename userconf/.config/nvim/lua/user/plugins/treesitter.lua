local config = require("user.config")
local treesitter_config = config.treesitter

local U = require("user.utils")
local F = require("user.functional")

local ensure_installed = config.minimal and {} or treesitter_config.ensure_installed

F.load("nvim-treesitter.parsers", function(tp)
  local configs = tp.get_parser_configs()
  vim.iter({ "jon", "cjon", "cjson" }):each(function(ft)
    local path = os.getenv("HOME") .. "/tree-sitter-" .. ft
    if U.exists(path) then
      configs[ft] = {
        install_info = {
          url = path,
          files = { "src/parser.c" },
        },
        filetype = { ft },
      }
    end
  end)
end)

F.load("nvim-treesitter.configs", function(tc)
  tc.setup({
    playground = {
      enable = false,
      updatetime = 25,
      persist_queries = false,
      keybindings = {
        toggle_query_editor = "o",
        toggle_hl_groups = "i",
        toggle_injected_languages = "t",
        toggle_anonymous_nodes = "a",
        toggle_language_display = "I",
        focus_language = "f",
        unfocus_language = "F",
        update = "R",
        goto_node = "<cr>",
        show_help = "?",
      },
    },
    highlight = {
      enable = true,
      disable = U.is_disable_treesitter,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = ")",
        node_incremental = ")",
        node_decremental = "(",
      },
    },
    matchup = {
      enable = false,
      disable = U.is_disable_treesitter,
    },
    indent = {
      enable = true,
      disable = U.is_disable_treesitter,
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ia"] = "@parameter.inner",
          ["aa"] = "@parameter.outer",
          ["ii"] = "@conditional.inner",
          ["ai"] = "@conditional.outer",
          ["al"] = "@loop.outer",
          ["il"] = "@loop.inner",
          ["a,"] = "@attribute.outer",
          ["i,"] = "@attribute.inner",
          [","] = "@assignment.lhs",
          ["."] = "@assignment.rhs",
          ["au"] = "@block.outer",
          ["iu"] = "@block.inner",
          ["ac"] = "@call.outer",
          ["ic"] = "@call.inner",
          ["ar"] = "@return.outer",
          ["ir"] = "@return.inner",
          ["a="] = "@assignment.outer",
          ["i="] = "@assignment.inner",
          ["ak"] = "@class.outer",
          ["ik"] = "@class.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          -- ["}"] = "@function.outer",
          ['"'] = "@class.outer",
        },
        -- goto_next_end = {
        --   ["]M"] = "@function.outer",
        --   ["]["] = "@class.outer",
        -- },
        goto_previous_start = {
          -- ["{"] = "@function.outer",
          ["!"] = "@class.outer",
        },
        -- goto_previous_end = {
        --   ["[M"] = "@function.outer",
        --   ["[]"] = "@class.outer",
        -- },
      },
      -- swap = {
      --   enable = true,
      --   swap_next = {
      --     ["U"] = "@parameter.inner",
      --   },
      --   swap_previous = {
      --     ["R"] = "@parameter.inner",
      --   },
      -- },
    },
    autotag = {
      enable = true,
      disable = U.is_disable_treesitter,
      enable_close_on_slash = false,
    },
    markid = { enable = true },
    ensure_installed = ensure_installed,
    ignore_install = treesitter_config.ignore_install,
    additional_vim_regex_highlighting = false,
  })
end)

F.load("treesitter-context", function(treesitter_context)
  treesitter_context.setup({
    multiline_threshold = 1,
    on_attach = function(bufnr)
      local filetype = vim.bo[bufnr].filetype
      return not U.is_disable_treesitter(filetype, bufnr)
    end,
  })
end)

F.load("hlargs", function(hlargs)
  hlargs.setup({
    paint_arg_declarations = false,
    color = "#16e5a4",
    disable = U.is_disable_treesitter,
    excluded_argnames = {
      declarations = {},
      usages = {
        python = { "self", "cls" },
        lua = { "self" },
      },
    },
  })
end)
