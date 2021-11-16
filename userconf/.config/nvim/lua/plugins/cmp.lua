local api = vim.api
local bo = vim.bo
local fn = vim.fn
local map = api.nvim_set_keymap

local lspkind = require("lspkind")
local luasnip = require("luasnip")
local cmp = require("cmp")

lspkind.init({
	with_text = true,
	-- preset = 'codicons',
	preset = "default",
	symbol_map = require("config").lspkind_symbol_map,
})

local has_empty_before = function()
	if bo.buftype == "prompt" then
		return false
	end
	local line, col = unpack(api.nvim_win_get_cursor(0))
	return api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(0, col):match("^%s*$") ~= nil
end

local t = function(key)
	return api.nvim_replace_termcodes(key, true, true, true)
end

local feedkey = function(key, mode)
	api.nvim_feedkeys(t(key), mode, true)
end

local tab_complete = function(fallback)
	if fn.pumvisible() == 1 then
		feedkey("<C-n>", "n")
	elseif cmp.visible() then
		cmp.select_next_item()
	else
		fallback()
	end
end

local s_tab_complete = function(fallback)
	if fn.pumvisible() == 1 then
		feedkey("<C-p>", "n")
	elseif cmp.visible() then
		cmp.select_prev_item()
	else
		fallback()
	end
end

local alt_tab_complete = function(fallback)
	if cmp.visible() then
		cmp.select_next_item()
	else
		fallback()
	end
end

local alt_s_tab_complete = function(fallback)
	if cmp.visible() then
		cmp.select_prev_item()
	else
		fallback()
	end
end


function JumpNext()
	if luasnip and luasnip.jumpable(1) then
		feedkey("<Plug>luasnip-jump-next", "")
	end
end

function JumpPrev()
	if luasnip and luasnip.jumpable(-1) then
		feedkey("<Plug>luasnip-jump-prev", "")
	end
end

local toggle_completion = cmp.mapping(function()
	if fn.pumvisible() == 1 then
		cmp.close()
	else
		cmp.complete()
	end
end)

cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	formatting = {
		format = function(entry, vim_item)
			vim_item.kind = lspkind.presets.default[vim_item.kind]
			vim_item.menu = ({
				buffer = "[Buffer]",
				nvim_lsp = "[LSP]",
				luasnip = "[Snippet]",
        tmux = "[Tmux]",
				nvim_lua = "[Lua]",
				latex_symbols = "[Latex]",
				path = "[Path]",
			})[entry.source.name]
			return vim_item
		end,
	},
	mapping = {
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<Tab>"] = tab_complete,
		["<S-Tab>"] = s_tab_complete,
		["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
	},
	sources = {
		{ name = "nvim_lsp" },
		{ name = "nvim_lua" },
		{ name = "luasnip" },
		{ name = "path" },
		{ name = "tmux" },
		{ name = "buffer", opts = {
			get_bufnrs = function()
				return api.nvim_list_bufs()
			end,
		} },
	},
})

map("", "<C-y>", "<CMD>lua JumpPrev()<CR>", {})
map("i", "<C-y>", "<CMD>lua JumpPrev()<CR>", {})
map("", "<C-x>", "<CMD>lua JumpNext()<CR>", {})
map("i", "<C-x>", "<CMD>lua JumpNext()<CR>", {})
