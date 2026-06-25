-- Inline image rendering + mermaid diagrams.
--
-- WezTerm's kitty-graphics implementation is not officially supported by
-- image.nvim (slow, non-compliant), so we use the SIXEL backend, which WezTerm
-- supports well. The `magick_cli` processor shells out to ImageMagick instead
-- of the `magick` luarock, so no luarocks setup is needed (see common/neovim.nix
-- for the imagemagick + mermaid-cli packages).
return {
  {
    "3rd/image.nvim",
    event = "VeryLazy",
    opts = {
      -- WezTerm supports the kitty graphics protocol; image.nvim labels it
      -- "unofficial" but, unlike sixel, it has real image placement/clearing,
      -- which sixel lacks — sixel dumps raw DCS payload as text when nvim's
      -- redraw interleaves (e.g. diagram.nvim's hover tab). Kitty avoids that.
      backend = "kitty",
      processor = "magick_cli",
      -- No window-percentage caps: image.nvim already clamps WIDTH to the
      -- window (height scrolls). A height cap would force-shrink tall diagrams
      -- and make their text tiny — exactly what we don't want. We control size
      -- via the mermaid `width` below instead.
      integrations = {
        markdown = {
          enabled = true,
          only_render_image_at_cursor = true,
        },
      },
    },
  },

  {
    "3rd/diagram.nvim",
    dependencies = { "3rd/image.nvim" },
    ft = { "markdown" },
    -- <leader>dz: "zoom" the mermaid diagram under the cursor in imv (real
    -- pan/zoom). The inline image.nvim render is a static raster with no zoom;
    -- diagram.nvim caches each diagram's PNG at sha256("mermaid:"..source).png
    -- (source-only — our render options don't change the path), so we resolve
    -- the diagram at the cursor and open its already-rendered PNG directly.
    keys = {
      {
        "<leader>dz",
        function()
          local bufnr = vim.api.nvim_get_current_buf()
          if vim.bo[bufnr].filetype ~= "markdown" then
            vim.notify("Not a markdown buffer", vim.log.levels.WARN)
            return
          end

          local md = require "diagram.integrations.markdown"
          local mermaid = require "diagram.renderers.mermaid"
          local diagrams = md.query_buffer_diagrams(bufnr)
          if #diagrams == 0 then
            vim.notify("No diagram in this buffer", vim.log.levels.INFO)
            return
          end

          -- Pick the diagram whose fenced block contains the cursor (expand the
          -- treesitter range out to the ``` fences, like diagram.nvim's hover).
          local cursor_row = vim.api.nvim_win_get_cursor(0)[1] - 1
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
          local chosen
          for _, d in ipairs(diagrams) do
            if d.renderer_id == "mermaid" then
              local sr, er = d.range.start_row, d.range.end_row
              for i = sr, 0, -1 do
                if lines[i + 1] and lines[i + 1]:match "^%s*```" then sr = i break end
              end
              for i = er, #lines - 1 do
                if lines[i + 1] and lines[i + 1]:match "^%s*```%s*$" then er = i break end
              end
              if cursor_row >= sr and cursor_row <= er then chosen = d break end
            end
          end
          chosen = chosen or diagrams[1]

          local function open(path)
            vim.fn.jobstart({ "imv", path }, { detach = true })
          end

          -- Cached → returns { file_path } with no job_id; else renders async.
          local res = mermaid.render(chosen.source, { background = "white", theme = "default" })
          if not res then return end
          if not res.job_id then
            open(res.file_path)
            return
          end
          local timer = vim.uv.new_timer()
          timer:start(100, 100, vim.schedule_wrap(function()
            if vim.fn.jobwait({ res.job_id }, 0)[1] == -1 then return end
            timer:stop()
            timer:close()
            if vim.fn.filereadable(res.file_path) == 1 then
              open(res.file_path)
            else
              vim.notify("Diagram render failed", vim.log.levels.ERROR)
            end
          end))
        end,
        desc = "Zoom diagram at cursor in imv",
      },
    },
    config = function()
      require("diagram").setup {
        integrations = {
          require "diagram.integrations.markdown",
        },
        renderer_options = {
          mermaid = {
            -- mermaid's default theme is dark-on-light; a white box keeps it
            -- legible against the Catppuccin Mocha background.
            background = "white",
            theme = "default",
            -- Render the PNG ~as wide as the editor window (in pixels) so
            -- image.nvim maps it ~1:1 (no downscaling = max readable text +
            -- crisp). TODO: set to (screen_cols × cell_width) measured via
            --   :lua print(vim.inspect(require('image.utils.term').get_size()))
            -- 1400 is a placeholder for a ~FHD window; raise on HiDPI.
            width = 1400,
            -- scale = device pixel ratio on top of `width`; 2 = retina-crisp.
            scale = 2,
          },
        },
      }
    end,
  },
}
