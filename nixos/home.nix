{ config, pkgs, ... }:

{
  imports = [
    ./neovim.nix
    ./tmux.nix
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
    xdg-utils
  ];

  # ~/.config/niri/config.kdl
  xdg.configFile."niri/config.kdl".text = ''
    // Basic Niri configuration. Noctalia starts with this session only.
    spawn-at-startup "noctalia"

    input {
        keyboard {
            xkb {
                layout "us"
            }
        }
        touchpad {
            tap
            dwt
        }
    }

    output "eDP-1" {
        mode "1920x1080@60.000"
        scale 1.0
    }

    binds {
        Mod+Return { spawn "alacritty"; }
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
    }

    layout {
        gaps 2
        default-column-width { proportion 0.5; }
    }

    window-rule {
        geometry-corner-radius 20
        clip-to-geometry true
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
}
