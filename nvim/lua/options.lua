require "nvchad.options"

-- add yours here!

local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!


-- Always show native tab bar
o.showtabline = 2

-- Fast key-code timeout (avoids phantom Alt in tmux)
o.ttimeout = true
o.ttimeoutlen = 5

-- Line endings: prefer unix detection; a file only reads as "dos" when
-- every line is CRLF (the statusline badge in chadrc.lua flags that case)
o.fileformats = "unix,dos"

-- Treesitter-based folding
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldlevel = 99 -- start with all folds open
