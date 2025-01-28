local opt = vim.opt

-- opt.number = true
opt.showcmd = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.smartindent = true
opt.autoindent = true
opt.hlsearch = true
opt.incsearch = true
opt.termguicolors = true
opt.cursorline = false
opt.showmode = true
opt.pumheight = 20
-- vim.o.mousemoveevent = true

local path_package = vim.fn.stdpath("data") .. "/site"
local mini_path = path_package .. "/pack/deps/start/mini.nvim"

if vim.fn.isdirectory(mini_path) == 0 then
	vim.cmd('echo "Installing `mini.nvim`" | redraw')
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch",
		"stable",
		"https://github.com/echasnovski/mini.nvim",
		mini_path,
	})
	vim.cmd("packadd mini.nvim | helptags ALL")
end

local mini_deps = require("mini.deps")
mini_deps.setup({ path = { package = path_package } })
local add, now = mini_deps.add, mini_deps.now

local mini_packages = {
	"icons",
	"completion",
	"comment",
	"pairs",
	"move",
	"pick",
	"statusline",
	"tabline",
	"clue",
	"files",
	"ai",
}

local core_packages = {
	{ source = "neovim/nvim-lspconfig", depends = { "williamboman/mason.nvim" } },
	{ source = "stevearc/conform.nvim" },
	{ source = "Mofiqul/vscode.nvim" },
	{ source = "EdenEast/nightfox.nvim" },
	{ source = "Bekaboo/dropbar.nvim" },
	{ source = "windwp/nvim-ts-autotag" },
	{ source = "lewis6991/gitsigns.nvim" },
	{ source = "brenton-leighton/multiple-cursors.nvim" },
	{ source = "lewis6991/hover.nvim" },
	{ source = "mrjones2014/legendary.nvim" },
	{ source = "stevearc/dressing.nvim" },
	{ source = "nvim-telescope/telescope.nvim", depends = { "nvim-lua/plenary.nvim" } },
	{ source = "jiaoshijie/undotree", depends = { "nvim-lua/plenary.nvim" } },
	{
		source = "zbirenbaum/copilot.lua",
		hooks = {
			pre_load = function()
				vim.api.nvim_create_autocmd("InsertEnter", {
					callback = function()
						require("mini.deps").load("copilot.lua")
					end,
				})
			end,
		},
	},
	{
		source = "nvim-treesitter/nvim-treesitter",
		checkout = "master",
		monitor = "main",
		hooks = {
			post_checkout = function()
				vim.cmd("TSUpdate")
			end,
		},
	},
}

for _, pkg in ipairs(core_packages) do
	add(pkg)
end

for _, pkg in ipairs(mini_packages) do
	add({
		source = "echasnovski/mini." .. pkg,
		checkout = "stable",
	})
end

now(function()
	require("nvim-treesitter.configs").setup({
		ensure_installed = { "lua", "vimdoc", "html", "tsx", "css" },
		highlight = {
			enable = true,
		},
		indent = {
			enable = true,
		},
	})

	require("conform").setup({
		formatters_by_ft = {
			lua = { "stylua" },
			javascript = { "prettierd" },
			typescript = { "prettierd" },
			javascriptreact = { "prettierd" },
			typescriptreact = { "prettierd" },
			css = { "prettierd" },
			html = { "prettierd" },
		},
		format_on_save = {
			timeout_ms = 500,
			lsp_format = "fallback",
		},
	})

	for _, pkg in ipairs(mini_packages) do
		require("mini." .. pkg).setup()
	end

	require("mason").setup()

	local miniclue = require("mini.clue")
	miniclue.setup({
		triggers = {
			{ mode = "n", keys = "<Leader>" },
			{ mode = "x", keys = "<Leader>" },
			{ mode = "i", keys = "<C-x>" },
			{ mode = "n", keys = "g" },
			{ mode = "x", keys = "g" },
			{ mode = "n", keys = "'" },
			{ mode = "n", keys = "`" },
			{ mode = "x", keys = "'" },
			{ mode = "x", keys = "`" },
			{ mode = "n", keys = '"' },
			{ mode = "x", keys = '"' },
			{ mode = "i", keys = "<C-r>" },
			{ mode = "c", keys = "<C-r>" },
			{ mode = "n", keys = "<C-w>" },
			{ mode = "n", keys = "z" },
			{ mode = "x", keys = "z" },
		},
		clues = {
			miniclue.gen_clues.builtin_completion(),
			miniclue.gen_clues.g(),
			miniclue.gen_clues.marks(),
			miniclue.gen_clues.registers(),
			miniclue.gen_clues.windows(),
			miniclue.gen_clues.z(),
		},
	})

	local lspconfig = require("lspconfig")

	lspconfig.lua_ls.setup({
		settings = {
			Lua = {
				diagnostics = { globals = { "vim" } },
				workspace = {
					library = {
						vim.fn.expand("$VIMRUNTIME/lua"),
						vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
					},
					checkThirdParty = false,
					maxPreload = 100000,
					preloadFileSize = 10000,
				},
				telemetry = { enable = false },
			},
		},
	})

	lspconfig.ts_ls.setup({
		init_options = {
			plugins = {
				{
					name = "@vue/typescript-plugin",
					location = "/usr/local/lib/node_modules/@vue/typescript-plugin",
					languages = { "javascript", "typescript", "vue" },
				},
			},
		},
		settings = {
			typescript = {
				inlayHints = {
					includeInlayParameterNameHints = "all",
					includeInlayParameterNameHintsWhenArgumentMatchesName = false,
					includeInlayFunctionParameterTypeHints = true,
					includeInlayVariableTypeHints = true,
					includeInlayPropertyDeclarationTypeHints = true,
					includeInlayFunctionLikeReturnTypeHints = true,
					includeInlayEnumMemberValueHints = true,
				},
			},
			javascript = {
				inlayHints = {
					includeInlayParameterNameHints = "all",
					includeInlayParameterNameHintsWhenArgumentMatchesName = false,
					includeInlayFunctionParameterTypeHints = true,
					includeInlayVariableTypeHints = true,
					includeInlayPropertyDeclarationTypeHints = true,
					includeInlayFunctionLikeReturnTypeHints = true,
					includeInlayEnumMemberValueHints = true,
				},
			},
		},
		filetypes = { "javascript", "typescript", "vue", "javascriptreact", "typescriptreact" },
	})

	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities.textDocument.completion.completionItem.snippetSupport = true

	require("lspconfig").cssls.setup({
		capabilities = capabilities,
	})

	local c = require("vscode.colors").get_colors()
	require("vscode").setup({
		italic_comments = true,
		underline_links = true,
		disable_nvimtree_bg = true,
		color_overrides = { vscLineNumber = "#FFFFFF" },
		group_overrides = {
			Cursor = { fg = c.vscDarkBlue, bg = c.vscLightGreen, bold = true },
		},
	})

	require("dropbar").setup()

	require("gitsigns").setup()

	require("nvim-ts-autotag").setup({
		opts = {
			enable_close = true,
			enable_rename = true,
			enable_close_on_slash = false,
		},
	})

	require("telescope").setup({
		defaults = {
			sorting_strategy = "ascending",
			file_sorter = require("mini.fuzzy").get_telescope_sorter,
			generic_sorter = require("mini.fuzzy").get_telescope_sorter,
		},
	})

	require("nvim-ts-autotag").setup({
		opts = {
			enable_close = true,
			enable_rename = true,
			enable_close_on_slash = false,
		},
	})

	require("multiple-cursors").setup()

	require("legendary").setup()

	require("undotree").setup()

	require("hover").setup({
		init = function()
			require("hover.providers.lsp")
		end,
		preview_opts = {
			border = "single",
		},
		preview_window = false,
		title = true,
		mouse_providers = {
			"LSP",
		},
		mouse_delay = 1000,
	})

	require("copilot").setup({
		panel = {
			auto_refresh = true,
			layout = {
				position = "right",
				ratio = 0.3,
			},
		},
		suggestion = {
			enable = true,
			auto_trigger = true,
			keymap = {
				accept = "<C-l>",
			},
		},
	})

	require("dressing").setup({
		select = {
			get_config = function(opts)
				if opts.kind == "legendary.nvim" then
					return {
						telescope = {
							sorter = require("telescope.sorters").fuzzy_with_index_bias({}),
						},
					}
				else
					return {}
				end
			end,
		},
	})

	require("mini.pairs").setup({
		mappings = {
			["{"] = {
				action = "open",
				pair = "{}",
				neigh_pattern = "[^\\].",
				registers = { cr = true },
			},
		},
	})

	local mini_files = require("mini.files")
	vim.keymap.set("n", "<C-l>", function()
		local minifiles_toggle = function(...)
			if not mini_files.close() then
				mini_files.open(...)
			end
		end
		minifiles_toggle()
	end, { noremap = true, silent = true })

	local mini_icons = require("mini.icons")
	mini_icons.setup()
	mini_icons.tweak_lsp_kind()
end)

_G.cr_action = function()
	if vim.fn.pumvisible() ~= 0 then
		local selected = vim.fn.complete_info().selected
		if selected ~= -1 then
			return vim.api.nvim_replace_termcodes("<C-y>", true, true, true)
		else
			return vim.api.nvim_replace_termcodes("<C-n><C-y>", true, true, true)
		end
	else
		return vim.api.nvim_replace_termcodes("<CR>", true, true, true)
	end
end

local imap_expr = function(lhs, rhs)
	vim.keymap.set("i", lhs, rhs, { expr = true })
end
imap_expr("<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]])
imap_expr("<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]])

local map = vim.keymap.set

map("i", "<CR>", "v:lua._G.cr_action()", { expr = true, noremap = true })
map("n", "dd", '"_dd', { noremap = true, silent = true })

map({ "n", "x" }, "<C-j>", "<Cmd>MultipleCursorsAddDown<CR>", { desc = "Add cursor and move down" })
map({ "n", "x" }, "<C-k>", "<Cmd>MultipleCursorsAddUp<CR>", { desc = "Add cursor and move up" })
map({ "n", "i", "x" }, "<C-Up>", "<Cmd>MultipleCursorsAddUp<CR>", { desc = "Add cursor and move up" })
map({ "n", "i", "x" }, "<C-Down>", "<Cmd>MultipleCursorsAddDown<CR>", { desc = "Add cursor and move down" })
map({ "n", "i" }, "<C-LeftMouse>", "<Cmd>MultipleCursorsMouseAddDelete<CR>", { desc = "Add or remove cursor" })
map({ "n", "x" }, "<Leader>a", "<Cmd>MultipleCursorsAddMatches<CR>", { desc = "Add cursors to cword" })
map(
	{ "n", "x" },
	"<Leader>A",
	"<Cmd>MultipleCursorsAddMatchesV<CR>",
	{ desc = "Add cursors to cword in previous area" }
)
map(
	{ "n", "x" },
	"<Leader>d",
	"<Cmd>MultipleCursorsAddJumpNextMatch<CR>",
	{ desc = "Add cursor and jump to next cword" }
)
map({ "n", "x" }, "<Leader>D", "<Cmd>MultipleCursorsJumpNextMatch<CR>", { desc = "Jump to next cword" })
map({ "n", "x" }, "<Leader>l", "<Cmd>MultipleCursorsLock<CR>", { desc = "Lock virtual cursors" })

map("n", "<Leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<Leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
map("n", "<Leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
map("n", "<Leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Find help" })
map({ "n", "i" }, "<Leader>u", "<cmd>lua require('undotree').toggle()<cr>", { desc = "Undotree" })
map({ "n", "x" }, "cp", '"+y')
map({ "n", "x" }, "cv", '"+p')
map("n", "cpl", '"+yy', { noremap = true, silent = true })

map("n", "K", require("hover").hover, { desc = "hover.nvim" })
map("n", "gK", require("hover").hover_select, { desc = "hover.nvim (select)" })
map("n", "<C-p>", function()
	require("hover").hover_switch("previous")
end, { desc = "hover.nvim (previous source)" })
map("n", "<C-n>", function()
	require("hover").hover_switch("next")
end, { desc = "hover.nvim (next source)" })

-- map("n", "<MouseMove>", require("hover").hover_mouse, { desc = "hover.nvim (mouse)" })

vim.cmd.colorscheme("vscode")
