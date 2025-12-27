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

-- Indent: TAB = 4 spazi
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true

-- Make
vim.opt.makeprg = "make -j"
vim.keymap.set("n", "<leader>m", "<cmd>make<cr>", { silent = true })
vim.keymap.set("n", "<leader>co", "<cmd>copen<cr>", { silent = true })
vim.keymap.set("n", "<leader>cc", "<cmd>cclose<cr>", { silent = true })
vim.keymap.set("n", "]q", "<cmd>cnext<cr>", { silent = true })
vim.keymap.set("n", "[q", "<cmd>cprev<cr>", { silent = true })

vim.keymap.set("n", "<leader>mt", function()
  vim.cmd("make " .. vim.fn.input("make target: "))
end, { silent = true })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { silent = true })

-- =========================
-- lazy.nvim
-- =========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- =========================
-- Plugins
-- =========================
require("lazy").setup({

  -- Tema scuro
  { "folke/tokyonight.nvim" },
  { "catppuccin/nvim",       name = "catppuccin" },
  { "rebelot/kanagawa.nvim" },
  { "EdenEast/nightfox.nvim" },
  { "sainnhe/gruvbox-material" },
  { "navarasu/onedark.nvim" },
  { "projekt0n/github-nvim-theme" },
  { "dracula/vim",           as = "dracula" },
  { "dasupradyumna/midnight.nvim" },
  { "shaunsingh/nord.nvim" },

  {
    'projekt0n/github-nvim-theme',
    name = 'github-theme',
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require('github-theme').setup({
        -- ...
      })

      vim.cmd('colorscheme github_dark_default')
    end,
  },
 

  -- Treesitter (highlight affidabile)
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- Autoclose parentesi / quote
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({})
    end
  },

  -- Surround
  {
      "kylechui/nvim-surround",
      version = "*",
      config = function()
          require("nvim-surround").setup()
      end
  },

  -- Smear Cursors
  {
      "sphamba/smear-cursor.nvim",
      config = function()
          require("smear_cursor").setup({
              stiffness = 0.6,
              trailing_stiffness = 0.25,
              distance_stop_animating = 0.5,
              hide_target_hack = true,
          })
      end
  },

  -- Completion popup
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      local enabled = true

      cmp.setup({
        enabled = function()
          return enabled
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
        }),
        completion = {
          autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged },
        },
      })

      -- Toggle autocomplete popup
      vim.keymap.set("n", "<leader>ac", function()
        enabled = not enabled
        vim.notify("autocomplete: " .. (enabled and "ON" or "OFF"))
      end, { silent = true })
    end
  },

  -- LSP
  { "neovim/nvim-lspconfig" },

  -- Telescope (file / grep / buffer)
  { "nvim-lua/plenary.nvim" },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({})
      local tb = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", tb.find_files, { silent = true })
      vim.keymap.set("n", "<leader>fg", tb.live_grep, { silent = true })
      vim.keymap.set("n", "<leader>fb", tb.buffers,   { silent = true })
      vim.keymap.set("n", "<leader>ds", tb.lsp_document_symbols,   { silent = true })
      vim.keymap.set("n", "<leader>ws", tb.lsp_dynamic_workspace_symbols,   { silent = true })
      vim.keymap.set("n", "<leader>od", tb.diagnostics,   { silent = true })
    end
  },

  -- Git
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end
  },
})

-- =========================
-- LSP nativo (Neovim 0.11+)
-- =========================
vim.diagnostic.config({ virtual_text = true, severity_sort = true })

-- Keymap LSP per-buffer quando un server si attacca
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local function map(m, lhs, rhs)
      vim.keymap.set(m, lhs, rhs, { buffer = ev.buf, silent = true })
    end

    map("n", "gd", vim.lsp.buf.definition)
    map("n", "gr", vim.lsp.buf.references)
    map("n", "gi", vim.lsp.buf.implementation)
    map("n", "K",  vim.lsp.buf.hover)
    map("n", "<leader>rn", vim.lsp.buf.rename)
    map("n", "<leader>ca", vim.lsp.buf.code_action)
    map("n", "<leader>f",  function() vim.lsp.buf.format({ async = true }) end)

    map("n", "]d", vim.diagnostic.goto_next)
    map("n", "[d", vim.diagnostic.goto_prev)
    map("n", "<leader>e", vim.diagnostic.open_float)
  end,
})

-- capabilities per nvim-cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Definisci/estendi la config di clangd
vim.lsp.config("clangd", {
  cmd = { "clangd", "--background-index", "--clang-tidy", "--query-driver=/usr/bin/g++"},
  capabilities = capabilities,
  filetypes = { "c", "cpp", "objc", "objcpp" },
  root_markers = { "compile_commands.json", "Makefile", "compile_flags.txt", ".git" },
})

-- Abilita clangd
vim.lsp.enable("clangd")


-- =========================
-- Diagnostica globale
-- =========================
vim.keymap.set("n", "<leader>q", function()
  vim.diagnostic.setqflist()
  vim.cmd("copen")
end, { silent = true })

