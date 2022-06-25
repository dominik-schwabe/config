local no_opt = {}
local def_opt = { silent = true }

local map_info = {}

map_info.asterisk = {
  mappings = {
    ["*"] = { { { "n", "x" }, "<Plug>(asterisk-*)", no_opt } },
    ["#"] = { { { "n", "x" }, "<Plug>(asterisk-#)", no_opt } },
    ["g*"] = { { { "n", "x" }, "<Plug>(asterisk-g*)", no_opt } },
    ["g#"] = { { { "n", "x" }, "<Plug>(asterisk-g#)", no_opt } },
    ["z*"] = { { { "n", "x" }, "<Plug>(asterisk-z*)", no_opt } },
    ["gz*"] = { { { "n", "x" }, "<Plug>(asterisk-gz*)", no_opt } },
    ["z#"] = { { { "n", "x" }, "<Plug>(asterisk-z#)", no_opt } },
    ["gz#"] = { { { "n", "x" }, "<Plug>(asterisk-gz#)", no_opt } },
  },
}

map_info.bufexplorer = {
  mappings = {
    ["<F2>"] = {
      { { "n", "x", "i" }, "<ESC>:ToggleBufExplorer<CR>", def_opt },
      { { "t" }, "<CMD>ToggleBufExplorer<CR>", def_opt },
    },
  },
}

map_info.markdown_preview = {
  mappings = {
    ["<space>m"] = { { { "n" }, "<CMD>MarkdownPreviewToggle<CR>", def_opt } },
  },
}

map_info.code_runner = {
  mappings = {
    ["<leader>r"] = { { { "n" }, "<CMD>RunCode<CR>", def_opt } },
  },
}

map_info.symbols_outline = {
  mappings = {
    ["<F3>"] = { { { "n", "i" }, "<CMD>SymbolsOutline<CR>", def_opt } },
  },
}

map_info.dap = {
  mappings = {
    ["<space>b"] = { { { "n" }, "<CMD>DapBreakpoint<CR>", def_opt } },
    ["<space>B"] = { { { "n" }, "<CMD>DapConditionalBreakpoint<CR>", def_opt } },
    ["<space>dpc"] = { { { "n" }, "<CMD>DapPythonClass<CR>", def_opt } },
    ["<space>dpm"] = { { { "n" }, "<CMD>DapPythonMethod<CR>", def_opt } },
    ["<space>dps"] = { { { "n", "x" }, "<CMD>DapPythonSelection<CR>", def_opt } },
    ["<F5>"] = { { { "n" }, "<CMD>DapStepOver<CR>", def_opt } },
    ["<F6>"] = { { { "n" }, "<CMD>DapStepInto<CR>", def_opt } },
    ["<F18>"] = { { { "n" }, "<CMD>DapStepOut<CR>", def_opt } },
    ["<F8>"] = { { { "n" }, "<CMD>DapContinue<CR>", def_opt } },
    ["<F20>"] = { { { "n" }, "<CMD>DapTerminate<CR>", def_opt } },
  },
}

map_info.hop = {
  mappings = {
    ["m"] = { { { "n" }, "<CMD>HopChar1<CR>", def_opt } },
    ["M"] = { { { "n" }, "<CMD>HopWord<CR>", def_opt } },
  },
}

map_info.comment_nvim = {
  mappings = {
    ["gc"] = {
      { { "n" }, "<Plug>(comment_toggle_current_linewise)", no_opt },
      { { "x" }, "<Plug>(comment_toggle_linewise_visual)", no_opt },
    },
    ["gb"] = {
      { { "n" }, "<Plug>(comment_toggle_current_blockwise)", no_opt },
      { { "x" }, "<Plug>(comment_toggle_blockwise_visual)", no_opt },
    },
  },
}

map_info.lspinstall = {
  mappings = {
    ["<space>li"] = { { { "n" }, ":LspInstall ", no_opt } },
    ["<space>lu"] = { { { "n" }, "<CMD>LspUpdate<CR>", no_opt } },
  },
}

map_info.nvim_lint = {
  mappings = {
    ["<space>z"] = { { { "n" }, "<CMD>Lint<CR>", no_opt } },
  },
}

map_info.treesitter_unit = {
  mappings = {
    ["iu"] = { { { "x", "o" }, "<CMD>lua require'treesitter-unit'.select(true)<CR>", def_opt } },
    ["au"] = { { { "x", "o" }, "<CMD>lua require'treesitter-unit'.select()<CR>", def_opt } },
  },
}

map_info.nvimtree = {
  mappings = {
    ["<F1>"] = {
      { { "n", "x", "i" }, "<ESC>:NvimTreeToggle<CR>", def_opt },
      { { "t" }, "<CMD>NvimTreeToggle<CR>", def_opt },
    },
    ["gt"] = { { { "n", "x" }, "<ESC>:NvimTreeFindFile<CR>", def_opt } },
  },
}

map_info.telescope = {
  mappings = {
    ["<C-p>"] = { { { "n", "x", "i" }, "<CMD>Telescope find_files<CR>", def_opt } },
    ["_"] = { { { "n", "x" }, "<CMD>Telescope live_grep<CR>", def_opt } },
    ["z="] = { { { "n" }, "<CMD>Telescope spell_suggest<CR><ESC>", def_opt } },
    ["<space>,,"] = { { { "n", "x" }, "<CMD>Telescope resume<CR>", def_opt } },
    ["<space>,c"] = { { { "n", "x" }, "<CMD>Telescope highlights<CR>", def_opt } },
    ["<space>,k"] = { { { "n", "x" }, "<CMD>Telescope keymaps<CR>", def_opt } },
    ["<space>,gb"] = { { { "n", "x" }, "<CMD>Telescope git_branches<CR>", def_opt } },
    ["<space>,gs"] = { { { "n", "x" }, "<CMD>Telescope git_status<CR>", def_opt } },
    ["<space>,h"] = { { { "n", "x" }, "<CMD>Telescope help_tags<CR>", def_opt } },
    ["<space>,j"] = { { { "n", "x" }, "<CMD>Telescope jumplist<CR>", def_opt } },
    ["<space>,s"] = { { { "n", "x" }, "<CMD>Telescope document_symbols<CR>", def_opt } },
    ["<space>,b"] = { { { "n", "x" }, "<CMD>Telescope current_buffer_fuzzy_find<CR>", def_opt } },
  },
}

map_info.todo_comments = {
  mappings = {
    ["<space>-"] = { { { "n" }, ":TodoQuickFix<CR>", def_opt } },
  },
}

map_info.trouble = {
  mappings = {
    ["ä"] = { { { "n", "x" }, "<cmd>TroubleToggle document_diagnostics<cr>", def_opt } },
  },
}

map_info.argwrap = {
  mappings = {
    ["Y"] = { { { "n", "x" }, ":ArgWrap<cr>", def_opt } },
  },
}

-- sideways TODO: find treesitter alternative
map_info.sideways = {
  mappings = {
    ["R"] = { { { "n" }, ":SidewaysLeft<cr>", def_opt } },
    ["U"] = { { { "n" }, ":SidewaysRight<CR>", def_opt } },
  },
}

-- map_info.yoink = {
--   mappings = {
--     ["ü"] = { { { "n" }, "<plug>(YoinkRotateBack)", {} } },
--     ["Ü"] = { { { "n" }, "<plug>(YoinkRotateForward)", {} } },
--     ["p"] = { { { "n" }, "<plug>(YoinkPaste_p)", {} } },
--     ["P"] = { { { "n" }, "<plug>(YoinkPaste_P)", {} } },
--     ["gp"] = { { { "n" }, "<plug>(YoinkPaste_gp)", {} } },
--     ["gP"] = { { { "n" }, "<plug>(YoinkPaste_gP)", {} } },
--   },
-- }

map_info.dial = {
  mappings = {
    ["<C-a>"] = { { { "n", "v" }, "<Plug>(dial-increment)", {} } },
    ["<C-x>"] = { { { "n", "v" }, "<Plug>(dial-decrement)", {} } },
    ["g<C-a>"] = { { { "v" }, "<Plug>(dial-increment-additional)", {} } },
    ["g<C-x>"] = { { { "v" }, "<Plug>(dial-decrement-additional)", {} } },
  },
}

map_info.icon_picker = {
  mappings = {
    ["<space>e"] = { { { "n" }, "<cmd>PickIcons<cr>", def_opt } },
  },
}

map_info.neo_zoom = {
  mappings = {
    ["<F12>"] = { { { "n", "x", "i", "t" }, "<cmd>NeoZoomToggle<cr>", def_opt } },
  },
}

map_info.default = {
  mappings = {
    ["<space>v"] = { { { "n", "x" }, "<CMD>lua ReloadConfig()<CR>", def_opt } },
    ["p"] = { { { "x" }, '"_dP', def_opt } },
    ["<space>P"] = { { { "x" }, "p", def_opt } },
    ["Q"] = { { { "n", "x" }, ":qa<CR>", def_opt } },
    ["<left>"] = { { { "n", "x" }, "<CMD>wincmd H<CR>", def_opt } },
    ["<right>"] = { { { "n", "x" }, "<CMD>wincmd L<CR>", def_opt } },
    ["<up>"] = { { { "n", "x" }, "<CMD>wincmd K<CR>", def_opt } },
    ["<down>"] = { { { "n", "x" }, "<CMD>wincmd J<CR>", def_opt } },
    ["ö"] = { { { "n", "x" }, "<CMD>noh<CR>", def_opt } },
    ["<"] = { { { "x" }, "<gv", def_opt } },
    [">"] = { { { "x" }, ">gv", def_opt } },
    ["<C-w>"] = {
      { { "n", "x", "i" }, "<CMD>mark ' | echo 'marked ' .. expand('%:p:t') .. ' ' .. line('.') <CR>", no_opt },
    },
    ["<C-e>"] = { { { "t" }, "<CMD>TermLeave<CR>", def_opt } },
    ["<C-h>"] = { { { "n", "x", "i", "t" }, "<CMD>wincmd h<CR>", no_opt } },
    ["<C-j>"] = { { { "n", "x", "i", "t" }, "<CMD>wincmd j<CR>", no_opt } },
    ["<C-k>"] = { { { "n", "x", "i", "t" }, "<CMD>wincmd k<CR>", no_opt } },
    ["<C-l>"] = { { { "n", "x", "i", "t" }, "<CMD>wincmd l<CR>", no_opt } },
    ["db"] = { { { "n" }, "dvb", def_opt } },
    ["dB"] = { { { "n" }, "dvB", def_opt } },
    ["cb"] = { { { "n" }, "cvb", def_opt } },
    ["cB"] = { { { "n" }, "cvB", def_opt } },
    ["<C-g>"] = { { { "n" }, "2<C-g>", no_opt } },
    ["<leader>x"] = { { { "n", "x" }, "<CMD>ChmodSet<CR>", def_opt } },
    ["<leader>X"] = { { { "n", "x" }, "<CMD>ChmodRemove<CR>", def_opt } },
    ["Ä"] = { { { "n", "x" }, "<CMD>LoclistToggle<CR>", def_opt } },
    ["Ö"] = { { { "n", "x" }, "<CMD>QuickfixToggle<CR>", def_opt } },
    ["<space>lds"] = { { { "n" }, "<CMD>LspSettings<CR>", def_opt } },
    ["<space>ldr"] = { { { "n" }, "<CMD>LspRoot<CR>", def_opt } },
    ["<space>s"] = { { { "x" }, "<CMD>SubstitudeSelection<CR>", def_opt } },
    ["gl"] = { { { "n" }, "<CMD>LatexSubstitude<CR>", def_opt } },
    ["+"] = { { { "n", "x" }, "<cmd>SmartResizeExpand<cr>", def_opt } },
    ["-"] = { { { "n", "x" }, "<cmd>SmartResizeReduce<cr>", def_opt } },
    ["<F10>"] = {
      { { "n", "x", "t" }, "<CMD>ToggleTerm 1<CR>", def_opt },
      { { "i" }, "<ESC>:ToggleTerm 1<CR>", def_opt },
    },
    ["<F22>"] = {
      { { "n", "x", "t" }, "<CMD>ToggleTermRight<CR>", def_opt },
      { { "i" }, "<ESC>:ToggleTermRight<CR>", def_opt },
    },
    ["<space>ss"] = { { { "n", "x" }, "<CMD>SetSpell<CR>", def_opt } },
    ["<space>sd"] = { { { "n", "x" }, "<CMD>SetSpell de_de<CR>", def_opt } },
    ["<space>se"] = { { { "n", "x" }, "<CMD>SetSpell en_us<CR>", def_opt } },
    -- ["n"] = { { { "n", "x" }, "nzzzv", def_opt } },
    -- ["N"] = { { { "n", "x" }, "Nzzzv", def_opt } },
    -- ["J"] = { { { "n", "x" }, "mzJ`z", def_opt } },
    ["<space>."] = { { { "n", "x" }, "<CMD>TrimWhitespace<CR>", def_opt } },
    ["<space>x"] = { { { "n", "x" }, "<CMD>lua Rg('setup', 10)<CR>", def_opt } },
    ["<c-_>"] = {
      { { "n" }, "<CMD>RgWord<CR>", def_opt },
      { { "x" }, "<ESC>:RgVisual<CR>", def_opt },
    },
    -- ["_"] = { { { "n" }, "<CMD>RgInput<CR>", def_opt } },
  },
}

M = {}

function M.setup()
  for _, plug_info in pairs(map_info) do
    for key, mappings in pairs(plug_info.mappings) do
      for _, mapping in pairs(mappings) do
        local modes, command, map_opts = unpack(mapping)
        for _, mode in pairs(modes) do
          vim.keymap.set(mode, key, command, map_opts)
        end
      end
    end
  end
end

function M.get_keys(plugin)
  local keys = {}
  for key, _ in pairs(map_info[plugin].mappings) do
    keys[#keys + 1] = key
  end
  return keys
end

return M
