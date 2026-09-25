{ config, pkgs, ... }:

{
  home.username = "von";
  home.homeDirectory = "/home/von";
  home.stateVersion = "26.11";
  
  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo i use nixos btw";
      nrs = "sudo nixos-rebuild switch -I nixos-config=/home/von/dotfiles/nixos/configuration.nix && source ~/.bashrc";
      nec = "vi /home/von/dotfiles/nixos/configuration.nix";
      neh = "vi /home/von/dotfiles/nixos/home.nix";
    };

    initExtra= ''
     PS1='\t \[\e[38;5;34m\]\u\[\e[0m\] in \[\e[38;5;33m\]\w\[\e[0m\] \\$ ' 
    '';
  };

  home.packages = with pkgs; [
    bat
  ];
}
