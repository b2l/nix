return {
  -- Disable nvim-tree (using oil instead)
  {
    "nvim-tree/nvim-tree.lua",
    enabled = false,
  },

  -- Fugitive
  {
    "tpope/vim-fugitive",
    cmd = { "G", "Git", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite", "GBrowse" },
    event = "BufReadPre",
  },

  -- Diffview (multi-file diffs, file history, merge conflicts)
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    opts = {
      enhanced_diff_hl = true,
    },
    config = function(_, opts)
      require("diffview").setup(opts)
      -- Word-level diff highlights (override base46 defaults)
      vim.api.nvim_set_hl(0, "DiffText", { bg = "#5B4A2E", bold = true })
      vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#2E4430" })
      vim.api.nvim_set_hl(0, "DiffChange", { bg = "#2E3544" })
      vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#442E2E" })
      -- Diffview-specific groups (used when enhanced_diff_hl = true)
      vim.api.nvim_set_hl(0, "DiffviewDiffText", { bg = "#5B4A2E", bold = true })
      vim.api.nvim_set_hl(0, "DiffviewDiffAdd", { bg = "#2E4430" })
      vim.api.nvim_set_hl(0, "DiffviewDiffChange", { bg = "#2E3544" })
      vim.api.nvim_set_hl(0, "DiffviewDiffDelete", { bg = "#442E2E" })
    end,
  },

  -- Present slides from .md file
  {
    "tjdevries/present.nvim",
    ft = "markdown",
    config = function()
      require("present").setup {}
    end,
  },

  -- Oil file browser
  {
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      columns = {
        "icon",
        "size",
      },
    },
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
    lazy = false,
    keys = {
      { "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
    },
  },

  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- ============================================================================
  -- Telescope config
  -- ============================================================================
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-live-grep-args.nvim",
    },
    opts = {
      defaults = {
        git_icons = {
          added = "A",
          changed = "M",
          copied = "C",
          deleted = "D",
          renamed = "R",
          unmerged = "??",
          untracked = "U",
        },
      },
      extensions = {
        live_grep_args = {
          auto_quoting = true,
        },
      },
    },
    config = function(_, opts)
      local telescope = require "telescope"
      telescope.setup(opts)
      telescope.load_extension "live_grep_args"
    end,
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- LSP document links (gl for $ref in OpenAPI/Swagger YAML)
  {
    "icholy/lsplinks.nvim",
    config = function()
      local lsplinks = require "lsplinks"
      lsplinks.setup()
      vim.keymap.set("n", "gl", lsplinks.gx, { desc = "Follow LSP link ($ref)" })
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "javascript",
        "typescript",
        "tsx",
        "json",
        "yaml",
      },
    },
  },

  -- ============================================================================
  -- Mini.nvim (surround, ai, move, pairs, etc.)
  -- ============================================================================
  {
    "echasnovski/mini.nvim",
    event = "VeryLazy",
    config = function()
      require("mini.ai").setup()
      require("mini.surround").setup()
      require("mini.move").setup()
      require("mini.pairs").setup()
      require("mini.operators").setup {
        replace = {
          prefix = "", -- Disable 'gr' to avoid conflict with LSP
        },
      }
      require("mini.splitjoin").setup()

      -- Define prominent OpenAPI highlight groups
      vim.api.nvim_set_hl(0, "OpenApiGet", { fg = "#61afef", bold = true }) -- Bright blue
      vim.api.nvim_set_hl(0, "OpenApiPost", { fg = "#98c379", bold = true }) -- Bright green
      vim.api.nvim_set_hl(0, "OpenApiPut", { fg = "#e5c07b", bold = true }) -- Bright yellow
      vim.api.nvim_set_hl(0, "OpenApiPatch", { fg = "#d19a66", bold = true }) -- Orange
      vim.api.nvim_set_hl(0, "OpenApiDelete", { fg = "#e06c75", bold = true }) -- Bright red
      vim.api.nvim_set_hl(0, "OpenApiRef", { fg = "#c678dd", bold = true }) -- Purple
      vim.api.nvim_set_hl(0, "OpenApi2xx", { fg = "#98c379", bold = true }) -- Green
      vim.api.nvim_set_hl(0, "OpenApi4xx", { fg = "#e5c07b", bold = true }) -- Yellow
      vim.api.nvim_set_hl(0, "OpenApi5xx", { fg = "#e06c75", bold = true }) -- Red

      local hipatterns = require "mini.hipatterns"
      hipatterns.setup {
        highlighters = {
          hex_color = hipatterns.gen_highlighter.hex_color(),

          -- OpenAPI highlighters (only for yaml files)
          openapi_get = {
            pattern = function(buf_id)
              if vim.bo[buf_id].filetype ~= "yaml" then
                return nil
              end
              return "^%s*get:"
            end,
            group = "OpenApiGet",
          },
          openapi_post = {
            pattern = function(buf_id)
              if vim.bo[buf_id].filetype ~= "yaml" then
                return nil
              end
              return "^%s*post:"
            end,
            group = "OpenApiPost",
          },
          openapi_put = {
            pattern = function(buf_id)
              if vim.bo[buf_id].filetype ~= "yaml" then
                return nil
              end
              return "^%s*put:"
            end,
            group = "OpenApiPut",
          },
          openapi_patch = {
            pattern = function(buf_id)
              if vim.bo[buf_id].filetype ~= "yaml" then
                return nil
              end
              return "^%s*patch:"
            end,
            group = "OpenApiPatch",
          },
          openapi_delete = {
            pattern = function(buf_id)
              if vim.bo[buf_id].filetype ~= "yaml" then
                return nil
              end
              return "^%s*delete:"
            end,
            group = "OpenApiDelete",
          },
          openapi_ref = {
            pattern = function(buf_id)
              if vim.bo[buf_id].filetype ~= "yaml" then
                return nil
              end
              return "%$ref:"
            end,
            group = "OpenApiRef",
          },
          openapi_2xx = {
            pattern = function(buf_id)
              if vim.bo[buf_id].filetype ~= "yaml" then
                return nil
              end
              return "^%s*['\"]?2%d%d['\"]?:"
            end,
            group = "OpenApi2xx",
          },
          openapi_4xx = {
            pattern = function(buf_id)
              if vim.bo[buf_id].filetype ~= "yaml" then
                return nil
              end
              return "^%s*['\"]?4%d%d['\"]?:"
            end,
            group = "OpenApi4xx",
          },
          openapi_5xx = {
            pattern = function(buf_id)
              if vim.bo[buf_id].filetype ~= "yaml" then
                return nil
              end
              return "^%s*['\"]?5%d%d['\"]?:"
            end,
            group = "OpenApi5xx",
          },
        },
      }
    end,
  },

  -- ============================================================================
  -- AI/Claude (<leader>a)
  -- ============================================================================
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      diff_opts = {
        open_in_current_tab = false, -- Open diffs in new tab when no editor window found
      },
    },
    keys = {
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add buffer to context" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude Code" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection" },
    },
  },

  -- ============================================================================
  -- GitHub Copilot
  -- ============================================================================
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup {
        suggestion = { enabled = false },
        panel = { enabled = false },
        filetypes = {
          ["*"] = true,
        },
      }
    end,
  },

  {
    "zbirenbaum/copilot-cmp",
    dependencies = "copilot.lua",
    event = "InsertEnter",
    config = function()
      require("copilot_cmp").setup()
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      table.insert(opts.sources, 1, { name = "copilot" })

      -- Add source labels to completion menu
      local format = opts.formatting.format
      opts.formatting.format = function(entry, vim_item)
        vim_item = format(entry, vim_item)
        local source_names = {
          copilot = "[Copilot]",
          nvim_lsp = "[LSP]",
          buffer = "[Buffer]",
          path = "[Path]",
        }
        vim_item.menu = source_names[entry.source.name] or vim_item.menu
        return vim_item
      end

      return opts
    end,
  },
}
