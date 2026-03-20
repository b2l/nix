require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "ts_ls", "yamlls" }
vim.lsp.enable(servers)

-- YAML Language Server config (OpenAPI support)
vim.lsp.config("yamlls", {
  settings = {
    yaml = {
      schemas = {
        ["https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.0/schema.json"] = "*.yaml",
      },
    },
  },
})

-- read :h vim.lsp.config for changing options of lsp servers 
