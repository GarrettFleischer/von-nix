# neovim — cheatsheet

- `vi` / `vim` / `vimdiff` aliases. Rebuild after config edits: `./rebuild.sh`.

## Layout

- `nixos/neovim.nix` — packages, LSP binaries, vimPlugins, wrapper args (`RUST_SRC_PATH`)
- `nixos/nvim/lua/von/{init,options,keymaps,plugins,lsp}.lua` — lua config (loaded as `require("von")`)

## Core options

| Setting | Value |
|---|---|
| Tabs | 2-space, spaces, smartindent |
| Numbers | relative, `signcolumn yes`, cursor line |
| Wrapping | soft-wrap off, `listchars` shows tab/trail/nbsp |
| Search | case-insensitive + smartcase, `grepprg = rg --vimgrep` |
| Splits | `inccommand split`, right/below, confirm |
| Undo | `undofile` on, no swap/backup files |
| Clipboard | `unnamedplus` (system clipboard) |
| Mouse | enabled; `termguicolors` |
| Theme | tokyonight-night |
| Diagnostics | `●` virtual text, underline, severity sort |

## Keymaps (leader = space)

| Key | What |
|---|---|
| `<sp>w` / `<sp>qq` | Save / Quit |
| `<sp>ff` / `<sp>fg` | Find files / Grep (Snacks pickers, `rg` under the hood) |
| `<sp>fb` / `<sp>fr` | Buffers / Recent files |
| `<sp>e` | File explorer (Snacks) |
| `<sp>fh` / `<sp>fs` | Help / LSP document symbols |
| `<sp>bd` | Delete buffer |
| `<sp>xx` | Diagnostics (Trouble) |
| `<sp>cf` | Format buffer (Conform) |
| `<sp>u` | Undotree toggle |
| `<sp>ca` / `<sp>rn` | Code action / Rename (LSP) |
| `<sp>cd` | Open line diagnostics float |
| `<sp>gg` | Lazygit |
| `<sp>hs` / `<sp>hr` / `<sp>hp` | Stage / Reset / Preview hunk |
| `<sp>hb` | Blame line |
| `]h` / `[h` | Next / Prev hunk |
| `<sp>db` / `<sp>dc` / `<sp>do` / `<sp>di` / `<sp>dO` | Toggle bp / Continue / Step over / Step into / Step out |
| `<sp>du` | Debug UI |

LSP-attached (per buffer, only when a server is running):

| Key | What |
|---|---|
| `gd` / `gr` / `gI` / `gy` | Goto definition / references / implementation / type def |
| `K` | Hover |
| `[d` / `]d` | Prev / next diagnostic |
| inlay hints | auto-enabled on attach (param names/types, etc.) |

## Completion (blink.cmp)

- Sources: `lsp` → `path` → `snippets` → `buffer` (friendly-snippets)
- `<Tab>`: select & accept (then snippet forward)
- `<S-Tab>`: snippet backward
- Docs auto-show after 200 ms; signatures inline

## LSP servers

| Server | Notes |
|---|---|
| rustaceanvim | rust-analyzer: `check = clippy`, `allFeatures`, proc macros. (Do not also enable rust-analyzer in `vim.lsp.enable`.) |
| clangd | `--background-index --clang-tidy --header-insertion=iwyu --completion-style=detailed --function-arg-placeholders --fallback-style=llvm` |
| vtsls | workspace TS SDK; inlay hints on; import style non-relative |
| eslint | workingDirectories auto |
| ruff | python; hover disabled (LspAttach) |
| lua_ls / nil_ls | `vim` in globals |
| others | html, cssls, jsonls, tailwindcss, emmet_ls, pyright, gopls, bashls, yamlls, taplo, dockerls, marksman, cmake |

## Formatting (Conform)

Manual: `<sp>cf` (async, LSP fallback). On save: yes, 3 s timeout.

| FT | Formatter |
|---|---|
| lua | stylua |
| rust | rustfmt |
| c / cpp | clang-format |
| python | ruff_format |
| go | gofumpt |
| nix | nixfmt |
| sh / bash | shfmt |
| js/ts/tsx/jsx, json/jsonc, html, css, scss, markdown, yaml | prettier |

## Debugging (DAP)

| Language | Adapter | Config |
|---|---|---|
| c / cpp | codelldb | `Launch file` (asks for executable path) |
| js / ts / tsx / jsx | pwa-node (js-debug) | `Launch file` / `Attach to process` |
| go | delve | `Debug file` |
| python | debugpy | `Launch file`; attach uses debugpy adapter |

## Other plugins

- **gitsigns** — inline git diffs; hunk nav/stage/reset/blame (see keymaps)
- **trouble** — diagnostics panel (`<sp>xx`)
- **undotree** — `<sp>u`
- **todo-comments** — highlight TODO/FIXME
- **crates** — Rust cargo commands
- **nvim-ts-autotag / rainbow-delimiters** — TS auto-close; colored parens
- **fidget** — spinner in statusline
- **lualine** — statusline
- **which-key** — `<leader>` group hints: buffer, code, debug, find, git, hunk, search
- **vim-tmux-navigator** — window nav via tmux
- **vim-sleuth** — vim-style undo
- **undotree**, **mini\* family** (pairs, surround, ai), **nvim-web-devicons**

## Treesitter

Grammar highlight + indent for: bash, c, cmake, css, dockerfile, go, html, javascript, json, lua, markdown, nix, python, query, regex, rust, scss, sql, toml, tsx, typescript, vim, yaml.

## Related sheets

- [niri keybinds & layout](niri.md)
- [Noctalia desktop](noctalia.md)
- [tmux](tmux.md)
- [shell/system shortcuts](shortcuts.md)
- [manuals](manuals.md)
