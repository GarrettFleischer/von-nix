{ pkgs, inputs, ... }: {
  imports = [
    ./neovim.nix
    ./tmux.nix
    ./home/hermes.nix
    inputs.hermes-agent.homeManagerModules.default
    inputs.zen-browser.homeModules.beta
  ];

  # ── Identity (these two together pick the right dotfiles tree) ──────────
  home.username = "von";
  home.homeDirectory = "/home/von";
  home.stateVersion = "26.11";

  # ── Shell ────────────────────────────────────────────────────────────────
  programs.bash = {
    enable = true;
    shellAliases = {
      # Editor shortcuts
      vi = "nvim";

      # NixOS/Home Manager workflow (flake lives at ~/dotfiles/nixos)
      nrs = "sudo nixos-rebuild switch --flake /home/von/dotfiles/nixos#nixos && source ~/.bashrc";
      nec = "nvim /home/von/dotfiles/nixos/configuration.nix";
      neh = "nvim /home/von/dotfiles/nixos/home.nix";
      sysupdate = "sudo nixos-rebuild switch --upgrade --flake /home/von/dotfiles/nixos#nixos && source ~/.bashrc";

      # Housekeeping
      gc = "nix store gc";

      # Fun
      btw = "echo i use nixos btw";
    };

    initExtra = ''
      PS1='\t \[\e[38;5;34m\]\u\[\e[0m\] in \[\e[38;5;33m\]\w\[\e[0m\] \\$ '
    '';
  };

  # ── Package set (shell tools, not editor plugins — those live in neovim.nix) ──
  home.packages = with pkgs; [
    alacritty
    bat
    bibata-cursors
    fuzzel
    swaybg
    xdg-utils
  ];

  # ── Browser ──────────────────────────────────────────────────────────────
  # Zen as the default browser (Firefox fork; prebuilt tarball, not in nixpkgs).
  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
  };

  # ── Environment ──────────────────────────────────────────────────────────
  home.sessionVariables = {
    # Cursor theme — fixes double-cursor issue (bibata-cursors shipped above).
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
  };

  # ── App config files (extracted from inline text blobs; each file is
  #     described by its own header). Paths are relative to $HOME/.config. ──
  #
  # Niri window manager — see home/niri-config.kdl for the full config.
  xdg.configFile."niri/config.kdl".source = ./home/niri-config.kdl;

  # Alacritty — frosted-glass terminal, Tokyo-Night. See home/alacritty.toml.
  xdg.configFile."alacritty/alacritty.toml".source = ./home/alacritty.toml;

  # Noctalia — compositor/launcher. See home/noctalia-config.toml.
  xdg.configFile."noctalia/config.toml".source = ./home/noctalia-config.toml;

  # GTK 3 — dark theme + glass transparency for Thunar. See:
  #   home/gtk-3.0-settings.ini  (theme/cursor selection)
  #   home/gtk-3.0-gtk.css       (glass + Tokyo-Night overrides)
  xdg.configFile."gtk-3.0/settings.ini".source = ./home/gtk-3.0-settings.ini;
  xdg.configFile."gtk-3.0/gtk.css".source = ./home/gtk-3.0-gtk.css;

  # GTK 4 — same spirit, GTK4 syntax. See: home/gtk-4.0-gtk.css
  xdg.configFile."gtk-4.0/gtk.css".source = ./home/gtk-4.0-gtk.css;
}
