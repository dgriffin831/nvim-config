-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.wrap = false
vim.opt.breakindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"
vim.opt.scrolloff = 8
vim.opt.undofile = true

-- Plugins
require("lazy").setup({
  -- Colorscheme
  { "catppuccin/nvim", name = "catppuccin", priority = 1000,
    config = function() vim.cmd.colorscheme("catppuccin-mocha") end },

  -- Treesitter (new API for main branch)
  { "nvim-treesitter/nvim-treesitter", lazy = false, build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({ "lua", "go", "typescript", "javascript", "tsx", "json", "yaml", "bash", "dockerfile", "markdown" })
    end },

  -- Telescope
  { "nvim-telescope/telescope.nvim", branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help" },
    }},

  -- Mason (LSP installer)
  { "williamboman/mason.nvim", config = true },

  -- Completion
  { "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip" },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = { { name = "nvim_lsp" }, { name = "buffer" }, { name = "luasnip" } },
      })
    end },

  -- File tree
  { "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = { { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "File tree" } },
    config = function() require("nvim-tree").setup() end },

  -- Git signs
  { "lewis6991/gitsigns.nvim", config = true },

  -- Status line
  { "nvim-lualine/lualine.nvim", config = function() require("lualine").setup({ options = { theme = "catppuccin" }}) end },

  -- Autopairs
  { "windwp/nvim-autopairs", event = "InsertEnter", config = true },

  -- Comments
  { "numToStr/Comment.nvim", config = true },
})

-- Enable treesitter highlighting for common filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "go", "typescript", "javascript", "typescriptreact", "javascriptreact", "json", "yaml", "bash", "sh", "dockerfile", "markdown" },
  callback = function() pcall(vim.treesitter.start) end,
})

-- Native LSP config (Neovim 0.11+)
vim.lsp.config("gopls", { cmd = { "gopls" }, filetypes = { "go", "gomod", "gowork", "gotmpl" } })
vim.lsp.config("ts_ls", { cmd = { "typescript-language-server", "--stdio" }, filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" } })
vim.lsp.config("lua_ls", { cmd = { "lua-language-server" }, filetypes = { "lua" }, settings = { Lua = { diagnostics = { globals = { "vim" } } } } })
vim.lsp.enable({ "gopls", "ts_ls", "lua_ls" })

-- LSP keymaps
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  end,
})

-- Keymaps
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
