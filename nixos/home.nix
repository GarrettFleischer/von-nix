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
    inputs.hermes-agent.homeManagerModules.default
    ./hermes.nix
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
      sysupdate = "sudo nixos-rebuild switch --upgrade --flake /home/von/dotfiles/nixos#nixos && source ~/.bashrc";
      gc = "nix store gc";
    };

    initExtra = ''
      PS1='\t \[\e[38;5;34m\]\u\[\e[0m\] in \[\e[38;5;33m\]\w\[\e[0m\] \\$ ' 
    '';
  };

  home.packages = with pkgs; [
    alacritty
    bat
    bibata-cursors
    fuzzel
    swaybg
    xdg-utils
  ];

  # Zen as the default browser
  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
  };

  # Cursor theme environment — fixes the double-cursor issue (no theme was
  # installed; bibata-cursors is now in home.packages above).
  home.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
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
    }

    cursor {
        hide-after-inactive-ms 1000
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
        Mod+B hotkey-overlay-title="Open Browser (Workspace 2)" {
            spawn-sh "niri msg focus-workspace b; spawn zen-browser";
        }
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

        Ctrl+h  { focus-column-left; }
        Ctrl+l { focus-column-right; }
        Ctrl+k    { focus-window-up; }
        Ctrl+j  { focus-window-down; }

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
            active-color "#7fc8ff"
            inactive-color "#505050"
        }
        border { off; }
    }

    window-rule {
        geometry-corner-radius 0
        clip-to-geometry true
    }
    window-rule {
        draw-border-with-background false
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

    # ── Bar: vertical on the left side ──
    # position | top | bottom | left | right
    # When left/right, thickness = bar width in px.
    [bar.main]
    position           = "left"
    thickness          = 60           # bar width
    background_opacity = 0.85         # glass bar: semi-transparent so wallpaper shows through
    radius             = 12
    margin_ends        = 180
    margin_edge        = 10
    padding            = 14
    widget_spacing     = 6
    scale              = 1.0
    font_scale         = 1.0
    shadow             = true
    auto_hide          = false
    reserve_space      = true
    capsule            = false

    # left-bar widget flow: top-to-bottom sections
    start  = ["launcher", "wallpaper", "workspaces"]
    center = ["clock"]
    end    = ["media", "tray", "notifications", "clipboard", "network", "bluetooth", "volume", "brightness", "battery", "control-center", "session"]

    [wallpaper]
    directory = "~/.config/wallpapers"

    [backdrop]
    enabled = true
    blur_intensity = 0.7
    tint_intensity = 0.2
  '';

  # ── GTK theme: Tokyo-Night palette + glass transparency for Thunar ──
  # Why: Noctalia's compositor does the blur, but GTK widgets are opaque
  # by default, so the wallpaper never shows through Thunar.
  #
  # How:
  #   • Global GTK settings point GTK3/4 apps at adwaita-dark (a real
  #     theme that matches the dark surface stack), then layer a user
  #     override stylesheet (gtk.css) on top.
  #   • The override sets semi-transparent backgrounds on windows, sidebar
  #     and view panels so Noctalia's backdrop blur paints behind them.
  #   • Tokyo-Night colors are pulled from the same palette Noctalia itself
  #     uses (surface = #1e1b2e, surface_container = #241f3d).

  # ~/.config/gtk-3.0/settings.ini
  xdg.configFile."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=Adwaita-dark
    gtk-application-prefer-dark-theme=true
    gtk-cursor-theme-name=Bibata-Modern-Ice
    gtk-cursor-theme-size=24
    gtk-toolbar-style=GTK_TOOLBAR_ICONS
    gtk-icon-theme-name=Adwaita
  '';

  # ~/.config/gtk-3.0/gtk.css — glass + Tokyo-Night
  xdg.configFile."gtk-3.0/gtk.css".text = ''
    /* ── Colors (Tokyo-Night, matching Noctalia's surface stack) ── */
    :root {
      --bg:        #1e1b2e;
      --bg-alpha:  rgba(30, 27, 46, 0.60);
      --panel:     #241f3d;
      --panel-alpha: rgba(36, 31, 61, 0.55);
      --fg:        #cdd6f4;
      --fg-dim:    #9399b2;
      --accent:    #7fc8ff;
      --selected:  #7fc8ff;
      --border:    rgba(127, 200, 255, 0.18);
    }

    /* ── Global window: let the wallpaper show through ── */
    window {
      background-color: var(--bg-alpha);
      color:            var(--fg);
    }

    /* ── Header bar (Thunar window title + toolbar) ── */
    .header-bar,
    .titlebar,
    .titlebar-backdrop {
      background-color: var(--panel-alpha);
      color:            var(--fg);
      border-bottom:    1px solid var(--border);
    }

    /* ── Sidebar ── */
    .sidebar,
    .sidebar .row,
    #sidebar-tree,
    .sidebar-button {
      background-color: var(--panel-alpha);
      color:            var(--fg);
    }

    .sidebar .row:selected,
    .sidebar .row:active {
      background-color: rgba(127, 200, 255, 0.20);
      color:            var(--fg);
    }

    /* ── Main view / file list ── */
    .view,
    .view:selected,
    .cell,
    .cell:selected,
    .treeview {
      background-color: var(--bg-alpha);
      color:            var(--fg);
    }

    .view:selected,
    .cell:selected {
      background-color: rgba(127, 200, 255, 0.18);
      color:            var(--fg);
    }

    /* ── Buttons & entries ── */
    button,
    .button,
    entry,
    .entry {
      background-color: var(--panel-alpha);
      color:            var(--fg);
      border:           1px solid var(--border);
      border-radius:    8px;
    }

    button:hover,
    .button:hover {
      background-color: rgba(127, 200, 255, 0.12);
    }

    /* ── Menus / popovers ── */
    menu,
    .menu,
    .popover {
      background-color: var(--bg-alpha);
      color:            var(--fg);
      border:           1px solid var(--border);
      border-radius:    8px;
    }

    .menuitem,
    .menu .menuitem {
      background-color: transparent;
      color:            var(--fg);
    }

    .menuitem:hover {
      background-color: rgba(127, 200, 255, 0.12);
    }

    /* ── Status bar / bottom panel ── */
    .status-bar,
    .statusbar {
      background-color: var(--panel-alpha);
      color:            var(--fg-dim);
      border-top:       1px solid var(--border);
    }

    /* ── Scroll bars ── */
    scrollbar,
    .scrollbar {
      background-color: var(--bg-alpha);
    }

    scrollbar slider,
    .scrollbar slider {
      background-color: var(--accent);
      border-radius:    4px;
    }

    /* ── Selection in tree / list (e.g. file list) ── */
    treeview row:selected,
    .view row:selected,
    .cell:selected {
      background-color: rgba(127, 200, 255, 0.18);
      color:            var(--fg);
    }

    /* ── Thunar-specific: path bar ── */
    #pathbar-box,
    .path-bar,
    .path-bar button {
      background-color: var(--panel-alpha);
      color:            var(--fg);
      border-bottom:    1px solid var(--border);
    }

    .path-bar button:hover {
      background-color: rgba(127, 200, 255, 0.12);
    }

    /* ── Thunar-specific: location bar (Oxygen/Pathbar) ── */
    #location-bar,
    .entry.location {
      background-color: var(--bg-alpha);
      color:            var(--fg);
      border:           1px solid var(--border);
      border-radius:    8px;
    }

    /* ── Thunar-specific: places / shortcut view ── */
    #places-view,
    .sidebar .row.separator {
      background-color: transparent;
    }

    .sidebar .row.separator {
      border-color: var(--border);
    }

    /* ── Scrollbar groove / trough styling ── */
    scrollbar trough,
    .scrollbar trough {
      background-color: transparent;
    }

    /* ── Print dialog / native dialogs ── */
    dialog,
    .dialog {
      background-color: var(--bg-alpha);
      color:            var(--fg);
      border:           1px solid var(--border);
      border-radius:    12px;
    }

    /* ── Overshoot / scrollable indicator ── */
    .overshoot {
      background:      none;
    }

    /* ── Ensure selection stays visible on hover ── */
    :selected {
      background-color: var(--selected);
      color:            var(--fg);
    }
  '';

  # ~/.config/gtk-4.0/gtk.css — same spirit, GTK4 syntax
  xdg.configFile."gtk-4.0/gtk.css".text = ''
    :root {
      --accent-bg-color:    #7fc8ff;
      --accent-fg-color:    #1e1b2e;
      --window-bg-color:    rgba(30, 27, 46, 0.55);
      --window-fg-color:    #cdd6f4;
      --view-bg-color:      rgba(30, 27, 46, 0.55);
      --view-fg-color:      #cdd6f4;
      --headerbar-bg-color: rgba(36, 31, 61, 0.55);
      --headerbar-fg-color: #cdd6f4;
      --popover-bg-color:   rgba(30, 27, 46, 0.60);
      --popover-fg-color:   #cdd6f4;
      --card-bg-color:      rgba(36, 31, 61, 0.55);
      --card-fg-color:      #cdd6f4;
      --sidebar-bg-color:   rgba(36, 31, 61, 0.55);
      --sidebar-fg-color:   #cdd6f4;
      --sidebar-border-color: rgba(127, 200, 255, 0.20);
      --shade-color:        rgba(0, 0, 0, 0.30);
    }

    /* glass for every top-level window */
    window {
      background-color: var(--window-bg-color);
    }

    headerbar {
      background-color: var(--headerbar-bg-color);
      color:            var(--headerbar-fg-color);
      border-bottom:    1px solid rgba(127, 200, 255, 0.18);
    }

    sidebar {
      background-color: var(--sidebar-bg-color);
      color:            var(--sidebar-fg-color);
      border-right:     1px solid var(--sidebar-border-color);
    }

    /* list / file view transparency */
    .list,
    .tree-view {
      background-color: var(--view-bg-color);
      color:            var(--view-fg-color);
    }

    /* selection */
    .list-row:selected,
    .tree-view-row:selected {
      background-color: rgba(127, 200, 255, 0.20);
      color:            var(--view-fg-color);
    }

    /* buttons */
    button {
      background-color: var(--card-bg-color);
      color:            var(--card-fg-color);
      border:           1px solid rgba(127, 200, 255, 0.18);
      border-radius:    8px;
    }

    button:hover {
      background-color: rgba(127, 200, 255, 0.12);
    }

    /* entries */
    entry {
      background-color: var(--window-bg-color);
      color:            var(--window-fg-color);
      border:           1px solid rgba(127, 200, 255, 0.18);
      border-radius:    8px;
    }

    /* popover / menu */
    popover {
      background-color: var(--popover-bg-color);
      color:            var(--popover-fg-color);
      border:           1px solid rgba(127, 200, 255, 0.18);
      border-radius:    8px;
    }

    /* scrollbar */
    scrollbar {
      background-color: var(--window-bg-color);
    }

    scrollbar slider {
      background-color: var(--accent-bg-color);
      border-radius:    4px;
    }
  '';

}
