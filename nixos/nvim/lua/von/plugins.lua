vim.cmd.colorscheme("tokyonight-night")

local icons = require("mini.icons")
icons.setup()
icons.mock_nvim_web_devicons()
require("mini.pairs").setup()
require("mini.surround").setup()
require("mini.ai").setup()

require("which-key").setup({
  spec = {
    { "<leader>b", group = "buffer" },
    { "<leader>c", group = "code" },
    { "<leader>d", group = "debug" },
    { "<leader>f", group = "find" },
    { "<leader>g", group = "git" },
    { "<leader>h", group = "hunk" },
    { "<leader>s", group = "search" },
  },
})

require("snacks").setup({
  bigfile = { enabled = true },
  dashboard = { enabled = true },
  explorer = { enabled = true },
  indent = { enabled = true },
  input = { enabled = true },
  notifier = { enabled = true, timeout = 3000 },
  picker = { enabled = true },
  quickfile = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = false },
  statuscolumn = { enabled = true },
  words = { enabled = true },
})

require("lualine").setup({
  options = {
    theme = "auto",
    globalstatus = true,
  },
})

require("gitsigns").setup({
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end
    map("n", "]h", function()
      gs.nav_hunk("next")
    end, "Next hunk")
    map("n", "[h", function()
      gs.nav_hunk("prev")
    end, "Previous hunk")
    map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
    map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
    map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
    map("n", "<leader>hb", function()
      gs.blame_line({ full = true })
    end, "Blame line")
  end,
})

require("trouble").setup({})
require("todo-comments").setup({})
require("fidget").setup({})
require("nvim-ts-autotag").setup({})
require("crates").setup({})

require("lazydev").setup({
  library = {
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
  },
})

local ok_configs, configs = pcall(require, "nvim-treesitter.configs")
if ok_configs then
  configs.setup({
    highlight = { enable = true },
    indent = { enable = true },
  })
else
  local ok_ts, ts = pcall(require, "nvim-treesitter")
  if ok_ts and type(ts.setup) == "function" then
    ts.setup({})
  end
  vim.api.nvim_create_autocmd("FileType", {
    callback = function(ev)
      pcall(vim.treesitter.start, ev.buf)
    end,
  })
end

require("blink.cmp").setup({
  keymap = {
    preset = "default",
    ["<Tab>"] = { "select_and_accept", "snippet_forward", "fallback" },
    ["<S-Tab>"] = { "snippet_backward", "fallback" },
  },
  appearance = { nerd_font_variant = "mono" },
  signature = { enabled = true },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
    list = { selection = { preselect = false, auto_insert = false } },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  fuzzy = {
    implementation = "prefer_rust_with_warning",
    prebuilt_binaries = { download = false },
  },
})

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    rust = { "rustfmt" },
    c = { "clang-format" },
    cpp = { "clang-format" },
    python = { "ruff_format" },
    go = { "gofumpt" },
    nix = { "nixfmt" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    json = { "prettier" },
    jsonc = { "prettier" },
    html = { "prettier" },
    css = { "prettier" },
    scss = { "prettier" },
    markdown = { "prettier" },
    yaml = { "prettier" },
  },
  default_format_opts = { lsp_format = "fallback" },
  format_on_save = { timeout_ms = 3000, lsp_format = "fallback" },
})

local dap = require("dap")
local dapui = require("dapui")
dapui.setup()
require("nvim-dap-virtual-text").setup()

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = "codelldb",
    args = { "--port", "${port}" },
  },
}

dap.configurations.cpp = {
  {
    name = "Launch file",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
  },
}
dap.configurations.c = dap.configurations.cpp

dap.adapters["pwa-node"] = {
  type = "server",
  host = "localhost",
  port = "${port}",
  executable = {
    command = "js-debug",
    args = { "${port}" },
  },
}

for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
  dap.configurations[language] = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      cwd = "${workspaceFolder}",
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach to process",
      processId = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
    },
  }
end

dap.adapters.delve = {
  type = "server",
  port = "${port}",
  executable = {
    command = "dlv",
    args = { "dap", "-l", "127.0.0.1:${port}" },
  },
}
dap.configurations.go = {
  {
    type = "delve",
    name = "Debug file",
    request = "launch",
    program = "${file}",
  },
}

dap.adapters.python = function(callback, config)
  if config.request == "attach" then
    local port = (config.connect or config).port
    callback({ type = "server", port = port, host = "127.0.0.1" })
  else
    callback({
      type = "executable",
      command = "python",
      args = { "-m", "debugpy.adapter" },
    })
  end
end
dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "Launch file",
    program = "${file}",
    pythonPath = "python",
  },
}
