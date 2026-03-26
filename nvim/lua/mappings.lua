require "nvchad.mappings"

local map = vim.keymap.set
local builtin = require "telescope.builtin"

-- General
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- ============================================================================
-- Explorer (Oil)
-- ============================================================================
map("n", "<leader>e", "<cmd>Oil<cr>", { desc = "Open file explorer" })

-- ============================================================================
-- Find/Files (<leader>f)
-- ============================================================================
map("n", "<leader><space>", builtin.find_files, { desc = "Find files" })
map("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
map("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
map("n", "<leader>fy", ':let @+ = expand("%")<CR>', { desc = "Copy file path" })

-- ============================================================================
-- Search (<leader>s)
-- ============================================================================
local live_grep_args = require("telescope").extensions.live_grep_args
map("n", "<leader>/", live_grep_args.live_grep_args, { desc = "Live grep (args)" })
map("n", "<leader>sg", live_grep_args.live_grep_args, { desc = "Live grep (args)" })
map("n", "<leader>sb", builtin.current_buffer_fuzzy_find, { desc = "Search buffer" })
map("n", "<leader>ss", builtin.lsp_document_symbols, { desc = "Document symbols" })
map("n", "<leader>sS", builtin.lsp_workspace_symbols, { desc = "Workspace symbols" })
map("n", "<leader>sr", builtin.registers, { desc = "Registers" })
map("n", "<leader>sc", builtin.command_history, { desc = "Command history" })
map("n", "<leader>sC", builtin.commands, { desc = "Commands" })
map("n", "<leader>sh", builtin.help_tags, { desc = "Help tags" })
map("n", "<leader>sk", builtin.keymaps, { desc = "Keymaps" })

-- ============================================================================
-- Git (<leader>g)
-- ============================================================================
map("n", "<leader>gs", builtin.git_status, { desc = "Git status" })
map("n", "<leader>gc", builtin.git_commits, { desc = "Git commits" })
map("n", "<leader>gC", builtin.git_bcommits, { desc = "Git buffer commits" })
map("n", "<leader>gB", builtin.git_branches, { desc = "Git branches" })
map("n", "<leader>gS", builtin.git_stash, { desc = "Git stash" })
map("n", "<leader>gD", "<cmd>DiffviewOpen<cr>", { desc = "Diffview open" })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "File history" })
map("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { desc = "Branch history" })
map("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" })
map("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", { desc = "Preview hunk" })
map("n", "<leader>gb", "<cmd>Gitsigns blame_line<cr>", { desc = "Blame line" })
map("n", "<leader>gd", "<cmd>Gitsigns diffthis<cr>", { desc = "Diff this" })
map("n", "]c", function()
  if vim.wo.diff then return "]c" end
  vim.schedule(function() require("gitsigns").next_hunk() end)
  return "<Ignore>"
end, { expr = true, desc = "Next hunk/diff change" })
map("n", "[c", function()
  if vim.wo.diff then return "[c" end
  vim.schedule(function() require("gitsigns").prev_hunk() end)
  return "<Ignore>"
end, { expr = true, desc = "Prev hunk/diff change" })

-- ============================================================================
-- Harpoon (<leader>h)
-- ============================================================================
local harpoon = require "harpoon"
map("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Harpoon add file" })
map("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })
map("n", "<C-1>", function() harpoon:list():select(1) end, { desc = "Harpoon file 1" })
map("n", "<C-2>", function() harpoon:list():select(2) end, { desc = "Harpoon file 2" })
map("n", "<C-3>", function() harpoon:list():select(3) end, { desc = "Harpoon file 3" })
map("n", "<C-4>", function() harpoon:list():select(4) end, { desc = "Harpoon file 4" })
map("n", "[h", function() harpoon:list():prev() end, { desc = "Harpoon prev" })
map("n", "]h", function() harpoon:list():next() end, { desc = "Harpoon next" })

-- ============================================================================
-- Buffers (<leader>b)
-- ============================================================================
map("n", "<leader>bb", builtin.buffers, { desc = "List buffers" })
map("n", "<leader>bd", function() require("nvchad.tabufline").close_buffer() end, { desc = "Delete buffer" })
map("n", "<leader>bo", ":%bd|e#|bd#<CR>", { desc = "Delete other buffers" })
map("n", "<S-l>", function() require("nvchad.tabufline").next() end, { desc = "Next buffer" })
map("n", "<S-h>", function() require("nvchad.tabufline").prev() end, { desc = "Previous buffer" })

-- ============================================================================
-- Code/LSP (<leader>c)
-- ============================================================================
map("n", "gd", function()
  vim.lsp.buf.definition({
    on_list = function(options)
      -- Jump directly to first result without opening quickfix
      if options.items and #options.items > 0 then
        local item = options.items[1]
        vim.cmd.edit(item.filename)
        vim.api.nvim_win_set_cursor(0, { item.lnum, item.col - 1 })
      end
    end
  })
end, { desc = "Go to definition" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>cr", builtin.lsp_references, { desc = "References" })
map("n", "<leader>ci", builtin.lsp_incoming_calls, { desc = "Incoming calls" })
map("n", "<leader>co", builtin.lsp_outgoing_calls, { desc = "Outgoing calls" })
map("n", "<leader>cd", builtin.lsp_definitions, { desc = "Go to definition" })
map("n", "<leader>cD", builtin.lsp_type_definitions, { desc = "Type definition" })
map("n", "<leader>ci", builtin.lsp_implementations, { desc = "Implementations" })
map("n", "<leader>cn", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>cf", function()
  require("conform").format { lsp_fallback = true }
end, { desc = "Format" })

-- ============================================================================
-- Diagnostics/Quickfix (<leader>x)
-- ============================================================================
map("n", "<leader>xx", builtin.diagnostics, { desc = "Diagnostics" })
map("n", "<leader>xd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>xq", builtin.quickfix, { desc = "Quickfix list" })
map("n", "<leader>xl", builtin.loclist, { desc = "Location list" })
map("n", "]]", "<cmd>cnext<CR>", { silent = true, desc = "Next quickfix" })
map("n", "[[", "<cmd>cprev<CR>", { silent = true, desc = "Prev quickfix" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })

-- ============================================================================
-- Terminal
-- ============================================================================
-- Disable NvChad terminal mappings (conflicts with mini.move / moving under <leader>t)
local nomap = vim.keymap.del
pcall(nomap, "n", "<A-h>")
pcall(nomap, "n", "<A-v>")
pcall(nomap, "n", "<A-i>")
pcall(nomap, "t", "<A-h>")
pcall(nomap, "t", "<A-v>")
pcall(nomap, "t", "<A-i>")
pcall(nomap, "n", "<leader>h")
pcall(nomap, "n", "<leader>v")

-- Horizontal / vertical terminal splits (NvChad)
map("n", "<leader>th", function()
  require("nvchad.term").new { pos = "sp" }
end, { desc = "Terminal horizontal split" })
map("n", "<leader>tv", function()
  require("nvchad.term").new { pos = "vsp" }
end, { desc = "Terminal vertical split" })

-- Floating terminal (Snacks.nvim)
local toggle_terminal = function()
  require("snacks").terminal.toggle(nil, { win = { position = "float" } })
end
map("n", "<leader>tt", toggle_terminal, { desc = "Toggle floating terminal" })
map("t", "<leader>tt", toggle_terminal, { desc = "Toggle floating terminal" })

-- Navigate out of terminal
map("t", "<C-h>", "<C-\\><C-n><C-W>h", { desc = "Navigate left" })
map("t", "<C-j>", "<C-\\><C-n><C-W>j", { desc = "Navigate down" })
map("t", "<C-k>", "<C-\\><C-n><C-W>k", { desc = "Navigate up" })
map("t", "<C-l>", "<C-\\><C-n><C-W>l", { desc = "Navigate right" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
