local config = require("user.config")
local treesitter_config = config.treesitter

local U = require("user.utils")
local F = require("user.functional")

local ensure_installed = config.minimal and {} or treesitter_config.ensure_installed

local function disable_func(filetype, bufnr)
  return U.is_big_buffer_whitelisted(bufnr) or F.contains(treesitter_config.highlight_disable, filetype)
end

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
      disable = disable_func,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = ")",
        node_incremental = ")",
        node_decremental = "(",
      },
    },
    markid = {
      enable = false,
      disable = disable_func,
      colors = {
        "#ffffff",
        "#eeeeee",
        "#dddddd",
        "#cccccc",
        "#bbbbbb",
        "#aaaaaa",
        "#999999",
        "#888888",
        "#777777",
        "#666666",
        "#555555",
      },
    },
    matchup = {
      enable = false,
      disable = disable_func,
    },
    indent = {
      enable = false,
      disable = disable_func,
    },
    rainbow = {
      enable = true,
      strategy = {
        function()
          local rb = F.load("ts-rainbow")
          if rb then
            local num_lines = vim.fn.line("$")
            if num_lines > 1000 then
              return rb.strategy["noop"]
              -- elseif num_lines > 1000 then
              --   return rb.strategy["global"]
            end
            return rb.strategy["global"]
          end
          return nil
        end,
      },
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
      swap = {
        enable = true,
        swap_next = {
          ["U"] = "@parameter.inner",
        },
        swap_previous = {
          ["R"] = "@parameter.inner",
        },
      },
    },
    autotag = {
      enable = true,
      disable = disable_func,
    },
    ensure_installed = ensure_installed,
    ignore_install = treesitter_config.ignore_install,
    context_commentstring = {
      enable = true,
      disable = disable_func,
      enable_autocmd = false,
    },
    additional_vim_regex_highlighting = false,
  })
end)

F.load("hlargs", function(hlargs)
  hlargs.setup({
    paint_arg_declarations = false,
    color = "#00ffaf",
    disable = disable_func,
    excluded_argnames = {
      declarations = {},
      usages = {
        python = { "self", "cls" },
        lua = { "self" },
      },
    },
  })
end)
