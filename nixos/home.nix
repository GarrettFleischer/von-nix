{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./neovim.nix
    ./tmux.nix
    inputs.zen-browser.homeModules.beta
  ];

  home.username = "von";
  home.homeDirectory = "/home/von";
  home.stateVersion = "26.11";

  programs.bash = {
    enable = true;
    shellAliases = {
      vi = "nvim";
      btw = "echo i use nixos btw";
      nrs = "sudo nixos-rebuild switch --flake /home/von/dotfiles/nixos#nixos && source ~/.bashrc";
      nec = "nvim /home/von/dotfiles/nixos/configuration.nix";
      neh = "nvim /home/von/dotfiles/nixos/home.nix";
    };

    initExtra = ''
      PS1='\t \[\e[38;5;34m\]\u\[\e[0m\] in \[\e[38;5;33m\]\w\[\e[0m\] \\$ ' 
    '';
  };

  home.packages = with pkgs; [
    alacritty
    bat
    fuzzel
    swaybg
    xdg-utils
  ];

  # Zen as the default browser
  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
  };

  # ~/.config/niri/config.kdl
  xdg.configFile."niri/config.kdl".text = ''
    // Riced Niri configuration (Tony's "niri-btw").
    // Noctalia starts with this session only.
    spawn-at-startup "noctalia"
    prefer-no-csd

    input {
        keyboard {
            repeat-delay 200
            repeat-rate 35
            xkb {
                layout "us"
            }
        }
        touchpad {
            tap
            dwt
        }
        focus-follows-mouse max-scroll-amount="0%"
    }

    output "eDP-1" {
        mode "2560x1440@60.000"
        scale 1.0
    }

    workspace "a"
    workspace "b"
    workspace "c"

    binds {
        Mod+T hotkey-overlay-title="Open a Terminal: alacritty" { spawn "alacritty"; }
        Mod+Q { close-window; }
        Mod+Shift+E { quit; }

        Mod+D hotkey-overlay-title="Run Application Launcher" {
            spawn-sh "noctalia msg panel-toggle launcher";
        }
        Mod+S hotkey-overlay-title="Control Center" {
            spawn-sh "noctalia msg panel-toggle control-center";
        }
        Mod+Comma hotkey-overlay-title="Noctalia Settings" {
            spawn-sh "noctalia msg settings-toggle";
        }
        Super+Alt+L hotkey-overlay-title="Lock Screen" {
            spawn-sh "noctalia msg session lock";
        }

        Mod+h  { focus-column-left; }
        Mod+l { focus-column-right; }
        Mod+k    { focus-window-up; }
        Mod+j  { focus-window-down; }

        Mod+Shift+h  { move-column-left; }
        Mod+Shift+l { move-column-right; }

        Mod+Shift+1 { move-column-to-workspace "a"; }
        Mod+Shift+2 { move-column-to-workspace "b"; }
        Mod+Shift+3 { move-column-to-workspace "c"; }
        Mod+Shift+4 { move-column-to-workspace "a"; }
        Mod+Shift+5 { move-column-to-workspace "b"; }
        Mod+Shift+6 { move-column-to-workspace "c"; }
        Mod+Shift+7 { move-column-to-workspace "a"; }
        Mod+Shift+8 { move-column-to-workspace "b"; }
        Mod+Shift+9 { move-column-to-workspace "c"; }
        // Open the Overview (zoomed-out view of workspaces and windows).
        Mod+O repeat=false { toggle-overview; }
        // Show the "Important Hotkeys" overlay.
        Mod+Space { show-hotkey-overlay; }
        // Switch workspace up/down.
        Mod+U { focus-workspace-down; }
        Mod+I { focus-workspace-up; }
        // Move the focused column to the workspace up/down.
        Mod+Ctrl+U { move-column-to-workspace-down; }
        Mod+Ctrl+I { move-column-to-workspace-up; }
        // Consume or expel the focused window left/right.
        Mod+BracketLeft { consume-or-expel-window-left; }
        Mod+BracketRight { consume-or-expel-window-right; }
        // Switch preset column width; maximize the column.
        Mod+R { switch-preset-column-width; }
        Mod+F { maximize-column; }
        // Toggle between floating and tiling; switch focus between floating and tiling.
        Mod+V { toggle-window-floating; }
        Mod+Shift+V { switch-focus-between-floating-and-tiling; }
    }

    layout {
        gaps 0
        default-column-width { proportion 0.5; }
        always-center-single-column
        focus-ring {
            width 1.5
            active-color "#ffffffff"
            inactive-color "#505050"
        }
        border { off; }
    }

    window-rule {
        geometry-corner-radius 0
        clip-to-geometry true
    }

    window-rule {
        // Frosted-glass: blur the wallpaper behind semi-transparent windows & popups.
        // Opaque apps (Firefox, editors) are unaffected.
        background-effect {
            xray true
            blur true
        }
        popups {
            background-effect {
                xray true
                blur true
            }
        }
    }

    window-rule {
        match app-id="dev.noctalia.Noctalia"
        open-floating true
        default-column-width { fixed 1080; }
        default-window-height { fixed 920; }
    }

    debug {
        honor-xdg-activation-with-invalid-serial
    }

    layer-rule {
        match namespace="^noctalia-backdrop"
        place-within-backdrop true
    }
  '';

  # ~/.config/alacritty/alacritty.toml — frosted-glass terminal, Tokyo-Night.
  xdg.configFile."alacritty/alacritty.toml".text = ''
    [window]
    decorations = "none"
    opacity = 0.5

    [colors.primary]
    background = "0x1e1b2b"
    foreground = "0xffffff"
  '';
  # ~/.config/noctalia/config.toml
  xdg.configFile."noctalia/config.toml".text = ''
    [theme]
    mode = "dark"
    source = "builtin"
    builtin = "Tokyo-Night"

    [shell]
    font_family = "JetBrainsMono Nerd Font Propo"
    [shell.panel]
    # Frosted-glass shell: semi-transparent bar/launcher/cards over the wallpaper.
    transparency_mode = "glass"

    [wallpaper]
    directory = "~/.config/wallpapers"

    [backdrop]
    enabled = true
    blur_intensity = 0.7
    tint_intensity = 0.2
  '';
}
