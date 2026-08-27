require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "ts_ls", "yamlls", "jdtls", "basedpyright", "ruff" }
vim.lsp.enable(servers)

-- Python: ruff handles lint/format/imports; basedpyright types/navigation
vim.lsp.config("basedpyright", {
  settings = {
    basedpyright = {
      disableOrganizeImports = true,
      -- Default "recommended" mode floods untyped codebases with reportUnknown* warnings
      analysis = { typeCheckingMode = "standard" },
    },
  },
})

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

-- JDTLS config (Java LSP - works with Maven/Gradle natively, sbt via sbt-eclipse)
-- .git finds repo root for multi-module sbt/maven/gradle projects
-- Single-module fallback: pom.xml, build.gradle, etc.
vim.lsp.config("jdtls", {
  root_markers = {
    { "mvnw", "gradlew", "settings.gradle", "settings.gradle.kts", ".git" },
    { "pom.xml", "build.gradle", "build.gradle.kts", "build.xml" },
  },
})

-- read :h vim.lsp.config for changing options of lsp servers
