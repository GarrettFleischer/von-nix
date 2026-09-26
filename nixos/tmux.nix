{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    prefix = "C-a";
    keyMode = "vi";
    mouse = true;
    focusEvents = true;
    escapeTime = 0;
    historyLimit = 100000;
    baseIndex = 1;
    clock24 = true;
    customPaneNavigationAndResize = true;
    disableConfirmationPrompt = true;
    sensibleOnTop = true;

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = yank;
        extraConfig = ''
          set -g @yank_selection_mouse 'clipboard'
        '';
      }
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
      vim-tmux-navigator
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor "mocha"
        '';
      }
    ];

    extraConfig = ''
      set -as terminal-features ",alacritty*:RGB,xterm-256color:RGB,tmux-256color:RGB"
      set -g set-clipboard on
      set -g renumber-windows on
      set -g status-position top
      set -g extended-keys on
      set -g allow-passthrough on

      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %
      bind c new-window -c "#{pane_current_path}"

      bind r source-file ~/.config/tmux/tmux.conf \; display "tmux reloaded"
    '';
  };
}
