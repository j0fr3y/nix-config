{ config, pkgs, lib, ... }:

{
  # Enable Wayland support
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Enable Wayland support for Electron apps
    MOZ_ENABLE_WAYLAND = "1"; # Enable Wayland for Firefox
  };

  # Install Hyprland compositor (modern Wayland compositor)
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Basic Wayland utilities
  environment.systemPackages = with pkgs; [
    # Wayland utilities
    wayland
    wayland-protocols
    wayland-utils
    wl-clipboard # Clipboard for Wayland
    
    # Screenshot and screen recording
    grim # Screenshot tool
    slurp # Screen area selection
    
    # Status bar and launcher
    waybar # Status bar
    wofi # Application launcher
    
    # Notifications
    mako # Notification daemon
    libnotify # Desktop notifications
    
    # Terminal
    kitty # Modern terminal with Wayland support
    
    # File manager
    xfce.thunar
    
    # Basic utilities
    pavucontrol # Audio control
    networkmanagerapplet # Network management
  ];

  # Enable XDG portal for screen sharing, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable dconf for GTK applications
  programs.dconf.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    font-awesome
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
  ];
}
