{ config, pkgs, ... }:

{
  imports = [
    ../modules/applications/neovim.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = "user";
  home.homeDirectory = "/home/user";

  # This value determines the Home Manager release that your configuration is compatible with
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "your.email@example.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };

  # Bash configuration
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ll = "ls -la";
      ".." = "cd ..";
      "..." = "cd ../..";
      gs = "git status";
      gp = "git pull";
      rebuild = "sudo nixos-rebuild switch --flake .#server";
    };
  };

  # Minimal packages for server
  home.packages = with pkgs; [
    # Development tools
    gcc
    python3
    
    # Utilities
    ripgrep
    fd
    tree
    jq
  ];
}
