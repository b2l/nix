require "nvchad.options"

-- add yours here!

local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!


-- Always show native tab bar
o.showtabline = 2

-- Fast key-code timeout (avoids phantom Alt in tmux)
o.ttimeout = true
o.ttimeoutlen = 5

-- Treesitter-based folding
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldlevel = 99 -- start with all folds open
