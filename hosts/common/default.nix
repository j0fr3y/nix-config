# Common configuration shared across all hosts
{ config, pkgs, lib, ... }:

{
  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Auto-optimize store
  nix.settings.auto-optimise-store = true;
  
  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Time zone (override per host if needed)
  time.timeZone = lib.mkDefault "Europe/Berlin";
  i18n.defaultLocale = lib.mkDefault "de_DE.UTF-8";

  # Essential packages for all systems
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    htop
    tmux
  ];

  # SSH configuration
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Default user setup (override properties per host)
  users.users.user = {
    isNormalUser = true;
    description = lib.mkDefault "User";
    extraGroups = [ "wheel" ];
    shell = pkgs.bash;
  };

  # System version
  system.stateVersion = lib.mkDefault "24.05";
}
