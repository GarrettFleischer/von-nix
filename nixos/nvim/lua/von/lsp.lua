vim.g.rustaceanvim = {
  server = {
    default_settings = {
      ["rust-analyzer"] = {
        cargo = { allFeatures = true },
        check = { command = "clippy" },
        procMacro = { enable = true },
      },
    },
  },
}

vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
  },
})

vim.lsp.config("vtsls", {
  settings = {
    vtsls = { autoUseWorkspaceTsdk = true },
    typescript = {
      updateImportsOnFileMove = { enabled = "always" },
      preferences = { importModuleSpecifier = "non-relative" },
      inlayHints = {
        parameterNames = { enabled = "literals" },
        parameterTypes = { enabled = true },
        variableTypes = { enabled = false },
        propertyDeclarationTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        enumMemberValues = { enabled = true },
      },
    },
    javascript = {
      inlayHints = {
        parameterNames = { enabled = "literals" },
        parameterTypes = { enabled = true },
        variableTypes = { enabled = false },
        propertyDeclarationTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
      },
    },
  },
})

vim.lsp.config("eslint", {
  settings = {
    workingDirectories = { mode = "auto" },
  },
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      telemetry = { enable = false },
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
    },
  },
})

vim.lsp.config("nil_ls", {
  settings = {
    ["nil"] = {
      formatting = { command = { "nixfmt" } },
    },
  },
})

-- rust-analyzer is started by rustaceanvim. Enabling it here attaches a second client.
vim.lsp.enable({
  "clangd",
  "vtsls",
  "eslint",
  "html",
  "cssls",
  "jsonls",
  "tailwindcss",
  "emmet_ls",
  "lua_ls",
  "nil_ls",
  "pyright",
  "ruff",
  "gopls",
  "bashls",
  "yamlls",
  "taplo",
  "dockerls",
  "marksman",
  "cmake",
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end
    pcall(vim.lsp.inlay_hint.enable, true, { bufnr = ev.buf })

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
    end
    map("n", "gd", vim.lsp.buf.definition, "Goto definition")
    map("n", "gr", vim.lsp.buf.references, "References")
    map("n", "gI", vim.lsp.buf.implementation, "Goto implementation")
    map("n", "gy", vim.lsp.buf.type_definition, "Goto type definition")
    map("n", "K", vim.lsp.buf.hover, "Hover")
    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
    map("n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
    map("n", "[d", function()
      vim.diagnostic.jump({ count = -1 })
    end, "Previous diagnostic")
    map("n", "]d", function()
      vim.diagnostic.jump({ count = 1 })
    end, "Next diagnostic")
  end,
})
