-- =========================
-- Base
-- =========================
vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 200
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.showmode = false -- il modo lo mostra gia' lualine

-- Indent: TAB = 4 spazi
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true

-- Disabilita netrw: lo sostituisce nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Quickfix (nav generica: LSP, grep, ecc. la riempiono comunque)
vim.keymap.set("n", "<leader>co", "<cmd>copen<cr>", { desc = "Quickfix open", silent = true })
vim.keymap.set("n", "<leader>cc", "<cmd>cclose<cr>", { desc = "Quickfix close", silent = true })
vim.keymap.set("n", "]q", "<cmd>cnext<cr>", { desc = "Quickfix next element", silent = true })
vim.keymap.set("n", "[q", "<cmd>cprev<cr>", { desc = "Quickfix prev element", silent = true })

-- Splitting Buffers
vim.keymap.set("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Vertical Split", silent = true })
vim.keymap.set("n", "<leader>-", "<cmd>split<cr>", { desc = "Horizontal Split", silent = true })

-- Rimuove Search Highlight
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Deselect Search Highlight", silent = true })

-- =========================
-- Plugin manager nativo: vim.pack (Neovim 0.12+)
-- =========================
local function gh(repo)
	return "https://github.com/" .. repo
end

vim.pack.add({
	-- Temi dark (tutti installati, si scelgono/preview con Telescope, vedi sotto)
	gh("folke/tokyonight.nvim"),
	gh("catppuccin/nvim"),
	gh("rebelot/kanagawa.nvim"),
	gh("EdenEast/nightfox.nvim"),
	gh("sainnhe/gruvbox-material"),
	gh("navarasu/onedark.nvim"),
	gh("projekt0n/github-nvim-theme"),
	gh("dracula/vim"),
	gh("dasupradyumna/midnight.nvim"),
	gh("shaunsingh/nord.nvim"),

	-- Treesitter (branch "main": nuova API, gestisce solo i parser)
	{ src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },

	-- Editing
	gh("windwp/nvim-autopairs"),
	gh("kylechui/nvim-surround"),

	-- Completion
	gh("hrsh7th/nvim-cmp"),
	gh("hrsh7th/cmp-nvim-lsp"),
	gh("hrsh7th/cmp-buffer"),
	gh("hrsh7th/cmp-path"),
	gh("L3MON4D3/LuaSnip"),
	gh("saadparwaiz1/cmp_luasnip"),
	gh("rafamadriz/friendly-snippets"),

	-- LSP + Mason (gestione automatica dei server)
	gh("neovim/nvim-lspconfig"),
	gh("mason-org/mason.nvim"),
	gh("mason-org/mason-lspconfig.nvim"),
	gh("WhoIsSethDaniel/mason-tool-installer.nvim"),

	-- Formatter/Linter
	gh("stevearc/conform.nvim"),

	-- File explorer
	gh("nvim-tree/nvim-tree.lua"),
	gh("nvim-tree/nvim-web-devicons"),

	-- Statusline
	gh("nvim-lualine/lualine.nvim"),

	-- Cheatsheet dei keymap
	gh("folke/which-key.nvim"),

	-- Cheatsheet comandi Vim/Neovim cercabile
	gh("doctorfree/cheatsheet.nvim"),

	-- Coaching attivo sui motion (nudge quando usi pattern inefficienti)
	gh("MunifTanjim/nui.nvim"),
	gh("m4xshen/hardtime.nvim"),

	-- Overlay dei motion disponibili sulla riga corrente
	gh("tris203/precognition.nvim"),

	-- Telescope (file / grep / buffer / temi)
	gh("nvim-lua/plenary.nvim"),
	gh("nvim-telescope/telescope.nvim"),

	-- Editing extra
	gh("numToStr/Comment.nvim"),

	-- Diagnostics/quickfix panel
	gh("folke/trouble.nvim"),

	-- TODO/FIXME/HACK highlighting
	gh("folke/todo-comments.nvim"),

	-- Terminale integrato
	gh("akinsho/toggleterm.nvim"),

	-- Sessioni per progetto
	gh("folke/persistence.nvim"),

	-- Debugging (DAP)
	gh("mfussenegger/nvim-dap"),
	gh("rcarriga/nvim-dap-ui"),
	gh("nvim-neotest/nvim-nio"),
	gh("jay-babu/mason-nvim-dap.nvim"),

	-- Git
	gh("lewis6991/gitsigns.nvim"),
})

-- =========================
-- Treesitter
-- =========================
-- Sul branch "main" il plugin installa solo i parser: highlight/indent li
-- attiviamo noi tramite le API native di Neovim.
local ts_langs = {
	"c",
	"cpp",
	"cuda",
	"python",
	"rust",
	"lua",
	"vim",
	"vimdoc",
	"query",
	"bash",
	"markdown",
	"markdown_inline",
	"diff",
}
require("nvim-treesitter").install(ts_langs)

vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		pcall(vim.treesitter.start)
	end,
})

-- =========================
-- Tema
-- =========================
local theme_file = vim.fn.stdpath("state") .. "/theme.txt"

local function load_saved_theme()
  local f = io.open(theme_file, "r")
  if f then
    local name = f:read("*l")
    f:close()
    if name and name ~= "" then
      return name
    end
  end
  return "github_dark_default"
end

local function apply_theme(name)
  if name:match("^github_") then
    require("github-theme").setup({})
  end
  local ok = pcall(vim.cmd.colorscheme, name)
  if not ok then
    vim.notify("Tema '" .. name .. "' non trovato, uso il default", vim.log.levels.WARN)
    require("github-theme").setup({})
    vim.cmd.colorscheme("github_dark_default")
  end
end

apply_theme(load_saved_theme())

-- =========================
-- Editing plugins
-- =========================
require("nvim-autopairs").setup({})
require("nvim-surround").setup({})
require("Comment").setup({})

-- =========================
-- Completion (nvim-cmp)
-- =========================
require("luasnip.loaders.from_vscode").lazy_load()

local cmp = require("cmp")
local luasnip = require("luasnip")

local cmp_enabled = true

cmp.setup({
	enabled = function()
		return cmp_enabled
	end,
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "path" },
		{ name = "buffer" },
	}),
	completion = {
		autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged },
	},
})

vim.keymap.set("n", "<leader>ac", function()
	cmp_enabled = not cmp_enabled
	vim.notify("autocomplete: " .. (cmp_enabled and "ON" or "OFF"))
end, { desc = "Autocomplete Status", silent = true })

-- =========================
-- Mason + LSP nativo
-- =========================
require("mason").setup({})

vim.diagnostic.config({ virtual_text = true, severity_sort = true })

-- capabilities condivise da nvim-cmp per tutti i server
vim.lsp.config("*", {
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

-- Config custom per clangd (flag specifici del progetto)
vim.lsp.config("clangd", {
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--query-driver=/usr/bin/g++,/usr/local/cuda/bin/nvcc",
		"--header-insertion=never",
	},
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
	root_markers = { "compile_commands.json", "Makefile", "compile_flags.txt", ".git" },
})

-- mason-lspconfig installa questi server e li abilita in automatico
-- (automatic_enable chiama vim.lsp.enable() da solo)
require("mason-lspconfig").setup({
	ensure_installed = { "clangd", "pyright", "rust_analyzer" },
})

-- Formatter/linter installati via Mason
-- NB: rustfmt non e' piu' nel registry di Mason, va installato con:
--   rustup component add rustfmt
require("mason-tool-installer").setup({
	ensure_installed = { "clang-format", "stylua", "ruff" },
})

-- Keymap LSP per-buffer quando un server si attacca
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local function map(m, lhs, rhs, desc)
			vim.keymap.set(m, lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
		end

		map("n", "gd", vim.lsp.buf.definition, "Goto Definition")
		map("n", "gr", vim.lsp.buf.references, "Goto References")
		map("n", "gi", vim.lsp.buf.implementation, "Goto Implementation")
		map("n", "K", vim.lsp.buf.hover, "Hover")
		map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
		map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")

		map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
		map("n", "[d", vim.diagnostic.goto_prev, "Prev Diagnostic")
		map("n", "<leader>dl", vim.diagnostic.open_float, "Diagnostic Float")
	end,
})

-- =========================
-- Trouble (pannello diagnostica/quickfix) + todo-comments
-- =========================
require("trouble").setup({})
vim.keymap.set(
	"n",
	"<leader>xx",
	"<cmd>Trouble diagnostics toggle<cr>",
	{ desc = "Diagnostics (Trouble)", silent = true }
)
vim.keymap.set("n", "<leader>xq", "<cmd>Trouble quickfix toggle<cr>", { desc = "Quickfix (Trouble)", silent = true })

require("todo-comments").setup({})
vim.keymap.set("n", "]t", function()
	require("todo-comments").jump_next()
end, { desc = "Next Todo", silent = true })
vim.keymap.set("n", "[t", function()
	require("todo-comments").jump_prev()
end, { desc = "Prev Todo", silent = true })
vim.keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find Todos", silent = true })

-- =========================
-- Formatting (conform.nvim, sostituisce vim.lsp.buf.format)
-- =========================
require("conform").setup({
	formatters_by_ft = {
		c = { "clang-format" },
		cpp = { "clang-format" },
		cuda = { "clang-format" },
		python = { "ruff_format" },
		rust = { "rustfmt" },
		lua = { "stylua" },
	},
	format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
})

vim.keymap.set({ "n", "v" }, "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format Buffer", silent = true })

-- =========================
-- Debugging (nvim-dap)
-- =========================
local dap = require("dap")
local dapui = require("dapui")

dapui.setup({})

require("mason-nvim-dap").setup({
	ensure_installed = { "codelldb", "debugpy" }, -- C/C++/Rust/CUDA + Python
	automatic_installation = true,
	handlers = {}, -- usa gli adapter di default per i tool sopra
})

dap.listeners.before.attach.dapui_config = function()
	dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
	dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
	dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
	dapui.close()
end

vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint", silent = true })
vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug Continue", silent = true })
vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Debug Step Into", silent = true })
vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Debug Step Over", silent = true })
vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Debug Step Out", silent = true })
vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Toggle Debug UI", silent = true })

-- =========================
-- File explorer (nvim-tree)
-- =========================
require("nvim-tree").setup({
	view = { width = 32 },
	renderer = { group_empty = true },
	filters = { dotfiles = false },
})
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle Explorer", silent = true })

-- =========================
-- Statusline (lualine)
-- =========================
require("lualine").setup({
	options = { theme = "auto", globalstatus = true },
})

-- =========================
-- Terminale integrato (toggleterm)
-- =========================
require("toggleterm").setup({
	open_mapping = [[<C-\>]],
	direction = "float",
})

-- =========================
-- Which-key (cheatsheet keymap)
-- =========================
require("which-key").setup({})

-- =========================
-- Cheatsheet cercabile (comandi Vim/Neovim, non solo i tuoi keymap)
-- =========================
require("cheatsheet").setup({})
vim.keymap.set("n", "<leader>?", "<cmd>Cheatsheet<cr>", { desc = "Cheatsheet", silent = true })

-- =========================
-- Hardtime: nudge in tempo reale sui pattern inefficienti
-- =========================
require("hardtime").setup({})

-- =========================
-- Precognition: overlay dei motion disponibili sulla riga
-- =========================
-- Parte disattivato per non essere invasivo: <leader>hp per accenderlo/spegnerlo
require("precognition").setup({ startVisible = false })
vim.keymap.set("n", "<leader>hp", function()
	require("precognition").toggle()
end, { desc = "Toggle Precognition Hints", silent = true })

-- =========================
-- Telescope (file / grep / buffer / temi)
-- =========================
require("telescope").setup({})
local tb = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", tb.find_files, { desc = "Find File", silent = true })
vim.keymap.set("n", "<leader>fg", tb.live_grep, { desc = "Live Grep", silent = true })
vim.keymap.set("n", "<leader>fb", tb.buffers, { desc = "Find Buffers", silent = true })
vim.keymap.set("n", "<leader>ds", tb.lsp_document_symbols, { desc = "Find Symbols", silent = true })
vim.keymap.set("n", "<leader>ws", tb.lsp_dynamic_workspace_symbols, { desc = "Find Workspace Symbols", silent = true })
vim.keymap.set("n", "<leader>od", tb.diagnostics, { desc = "Open Diagnostic", silent = true })
vim.keymap.set("n", "<leader>fz", tb.current_buffer_fuzzy_find, { desc = "Fuzzy Find", silent = true })


-- Colorscheme picker con anteprima live (frecce su/giu = preview, invio = applica e salva)
vim.keymap.set("n", "<leader>th", function()
  tb.colorscheme({
    enable_preview = true,
    attach_mappings = function(prompt_bufnr, map)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if selection then
          apply_theme(selection.value)
          local f = io.open(theme_file, "w")
          if f then
            f:write(selection.value)
            f:close()
          end
        end
      end)
      return true
    end,
  })
end, { desc = "Theme Picker (preview + save)", silent = true })

-- =========================
-- Git
-- =========================
require("gitsigns").setup({})

-- =========================
-- Sessioni per progetto (persistence.nvim)
-- =========================
require("persistence").setup({})
vim.keymap.set("n", "<leader>ss", function()
	require("persistence").load()
end, { desc = "Load Session", silent = true })
vim.keymap.set("n", "<leader>sl", function()
	require("persistence").load({ last = true })
end, { desc = "Load Last Session", silent = true })
vim.keymap.set("n", "<leader>sd", function()
	require("persistence").stop()
end, { desc = "Don't Save Session", silent = true })

-- =========================
-- Aggiorna highlight query dei parser dopo update di nvim-treesitter
-- =========================
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		if ev.data.spec.name == "nvim-treesitter" then
			vim.cmd("TSUpdate")
		end
	end,
})
