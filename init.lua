-- Enable line numbers
vim.wo.number = true

-- Set up color scheme
vim.o.termguicolors = true
vim.o.background = "dark"
vim.o.encoding = 'utf-8'

-- Set leader key to space
vim.g.mapleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin setup
require("lazy").setup({
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup({
        view = {
          side = 'left',
          width = 30,
        },
        renderer = {
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
            },
          },
        },
    	git = {
    	  ignore = false,
    	},
    	filters = {
    	  dotfiles = false,
    	  git_ignored = false,
    	},
      })

      -- Key mapping to toggle nvim-tree
      vim.api.nvim_set_keymap('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

      -- Automatically open nvim-tree when Neovim starts
      vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
          require("nvim-tree.api").tree.open()
          vim.defer_fn(function()
            vim.cmd("wincmd p")
          end, 0)
        end
      })
    end,
  },

  -- Treesitter for improved syntax highlighting
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd[[colorscheme tokyonight-night]]
    end,
  },

  -- Statusline with git info
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup {
        options = {
          icons_enabled = true,
          theme = 'tokyonight',
          component_separators = { left = '', right = ''},
          section_separators = { left = '', right = ''},
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {'filename'},
          lualine_x = {'encoding', 'fileformat', 'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {'filename'},
          lualine_x = {'location'},
          lualine_y = {},
          lualine_z = {}
        },
      }
    end,
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local luasnip = require("luasnip")

      lspconfig.pyright.setup{
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "workspace",
              useLibraryCodeForTypes = true
            }
          }
        }
      }

      lspconfig.tsserver.setup{
        filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
        cmd = { "typescript-language-server", "--stdio" },
        root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
      }

      lspconfig.rust_analyzer.setup{
        cmd = {"rust-analyzer"},
        filetypes = {"rust"},
        root_dir = lspconfig.util.root_pattern("Cargo.toml", "rust-project.json"),
        settings = {
          ["rust-analyzer"] = {
            assist = {
              importGranularity = "module",
              importPrefix = "self",
            },
            cargo = {
              loadOutDirsFromCheck = true
            },
            procMacro = {
              enable = true
            },
          }
        }
      }

      lspconfig.gopls.setup{
        cmd = {"gopls", "serve"},
        filetypes = {"go", "gomod"},
        root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
          },
        },
      }

      -- Key mappings for LSP functionality
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
          vim.keymap.set('n', '<leader>s', require('telescope.builtin').lsp_document_symbols, opts)
        end,
      })
    end,
  },

  -- Telescope for fuzzy finding
  {
    "nvim-telescope/telescope.nvim",
    tag = '0.1.5',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require('telescope.builtin')
      
      -- Basic keymaps for Telescope
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
    end
  },

  -- Add Codeium plugin
  {
    "Exafunction/codeium.vim",
    event = "BufEnter",
  },
})

-- Set up filetype detection for Python
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})

-- Set up filetype detection for Go
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})

-- Set up filetype detection for Rust
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})

-- Set up filetype detection for TypeScript
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"typescript", "typescriptreact"},
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- Enable mouse support
vim.o.mouse = 'a'

-- Enable clipboard integration
vim.o.clipboard = 'unnamedplus'
