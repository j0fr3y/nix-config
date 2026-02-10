{ config, pkgs, ... }:

{
  imports =
    [
      # Importiert die Hardware-Konfiguration (muss auf dem echten Server generiert werden!)
      ./hardware-configuration.nix
    ];

  # Bootloader Setup (Beispiel für systemd-boot, oft Standard)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "mein-server"; # Hostname setzen

  # Zeitzone und Sprache settings
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";

  # User Account Setup
  users.users.admin = {
    isNormalUser = true;
    description = "Admin User";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    openssh.authorizedKeys.keys = [
      # "ssh-ed25519 AAAAC3NzaC1lZDDI1NTE5AAAAIK..." # Füge hier deinen Public Key ein
    ];
  };

  # SSH aktivieren
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false; # Sicherheit: Nur Keys erlauben!
      PermitRootLogin = "prohibit-password";
    };
  };

  # Grundlegende Pakete
  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    curl
    wget
  ];

  # Nix Flakes aktivieren (wichtig!)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # System State Version (NICHT ändern nach Installation)
  system.stateVersion = "24.11";
}
