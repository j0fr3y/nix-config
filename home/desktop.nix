{ config, pkgs, ... }:

{
  imports = [
    ../modules/applications/neovim.nix
    ../modules/applications/vscode.nix
    ../modules/applications/firefox.nix
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
      rebuild = "sudo nixos-rebuild switch --flake .#desktop";
    };
  };

  # Additional packages for desktop
  home.packages = with pkgs; [
    # Development tools
    gcc
    nodejs
    python3
    
    # Utilities
    ripgrep
    fd
    btop
    tree
    jq
    
    # Archive tools
    unzip
    zip
    
    # Media
    vlc
    mpv
  ];

  # GTK theme
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };

  # Cursor theme
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
  };

  # Hyprland configuration
  xdg.configFile."hypr/hyprland.conf".source = ./config/hypr/hyprland.conf;

  # Waybar configuration
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "network" "battery" "tray" ];
        
        "hyprland/workspaces" = {
          format = "{id}";
        };
        
        clock = {
          format = "{:%H:%M}";
          format-alt = "{:%A, %B %d, %Y}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };
        
        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰖁 Muted";
          format-icons = {
            default = [ "" "" "" ];
          };
          on-click = "pavucontrol";
        };
        
        network = {
          format-wifi = "  {essid}";
          format-ethernet = "  Wired";
          format-disconnected = "󰖪 Disconnected";
          tooltip-format = "{ifname}: {ipaddr}";
        };
        
        battery = {
          format = "{icon} {capacity}%";
          format-icons = [ "" "" "" "" "" ];
          format-charging = " {capacity}%";
        };
      };
    };
    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrains Mono", "Font Awesome 6 Free";
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(30, 30, 46, 0.95);
        color: #cdd6f4;
      }

      #workspaces button {
        padding: 0 8px;
        color: #cdd6f4;
      }

      #workspaces button.active {
        background: rgba(137, 180, 250, 0.3);
        color: #89b4fa;
      }

      #workspaces button:hover {
        background: rgba(205, 214, 244, 0.1);
      }

      #clock,
      #pulseaudio,
      #network,
      #battery,
      #tray {
        padding: 0 10px;
        margin: 0 5px;
      }

      #pulseaudio {
        color: #89b4fa;
      }

      #network {
        color: #a6e3a1;
      }

      #battery {
        color: #f9e2af;
      }

      #battery.charging {
        color: #a6e3a1;
      }
    '';
  };
}
