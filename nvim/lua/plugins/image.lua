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
      backend = "sixel",
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
