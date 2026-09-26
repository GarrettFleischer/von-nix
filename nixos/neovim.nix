{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Toolchains used from the shell, not only inside the editor.
    rustc
    cargo
    clippy
    rustfmt
    clang
    gcc
    cmake
    ninja
    gnumake
    pkg-config
    nodejs
    typescript
    python3
    go
    lazygit
    wl-clipboard
    ripgrep
    fd
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withRuby = false;
    withNodeJs = false;

    extraWrapperArgs = [
      "--set"
      "RUST_SRC_PATH"
      "${pkgs.rust-src}/lib/rustlib/src/rust/library"
    ];

    extraPackages = with pkgs; [
      # Language servers
      clang-tools
      rust-analyzer
      vtsls
      vscode-langservers-extracted
      tailwindcss-language-server
      emmet-language-server
      lua-language-server
      nil
      pyright
      ruff
      gopls
      bash-language-server
      yaml-language-server
      taplo
      dockerfile-language-server
      marksman
      cmake-language-server
      # Formatters and linters
      prettier
      stylua
      nixfmt-rfc-style
      shfmt
      gofumpt
      shellcheck
      eslint
      # Debuggers
      codelldb
      vscode-js-debug
      delve
      (python3.withPackages (ps: [ ps.debugpy ]))
      # Pickers
      ripgrep
      fd
      git
    ];

    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins (p: [
        p.bash
        p.c
        p.cmake
        p.cpp
        p.css
        p.dockerfile
        p.go
        p.html
        p.javascript
        p.json
        p.lua
        p.markdown
        p.nix
        p.python
        p.query
        p.regex
        p.rust
        p.scss
        p.sql
        p.toml
        p.tsx
        p.typescript
        p.vim
        p.yaml
      ]))
      nvim-lspconfig
      blink-cmp
      friendly-snippets
      snacks-nvim
      conform-nvim
      gitsigns-nvim
      which-key-nvim
      lualine-nvim
      trouble-nvim
      todo-comments-nvim
      rustaceanvim
      crates-nvim
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text
      lazydev-nvim
      fidget-nvim
      mini-nvim
      nvim-web-devicons
      nvim-ts-autotag
      rainbow-delimiters-nvim
      tokyonight-nvim
      vim-sleuth
      undotree
      vim-tmux-navigator
    ];

    extraLuaConfig = ''
      require("von")
    '';
  };

  xdg.configFile."nvim/lua/von" = {
    source = ./nvim/lua/von;
    recursive = true;
  };
}
