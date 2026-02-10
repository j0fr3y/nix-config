# Quick Start Guide

This guide will help you get up and running with this NixOS configuration quickly.

## Installation on NixOS

### Desktop Installation

1. **Boot into NixOS installer**

2. **Clone the repository**:
   ```bash
   # Connect to internet (wifi-menu for WiFi, or use ethernet)
   sudo -i
   nix-shell -p git
   git clone https://github.com/j0fr3y/nix-config /mnt/etc/nixos
   cd /mnt/etc/nixos
   ```

3. **Generate hardware configuration**:
   ```bash
   nixos-generate-config --root /mnt
   cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/hosts/desktop/
   ```

4. **Edit host configuration**:
   ```bash
   nano /mnt/etc/nixos/hosts/desktop/configuration.nix
   ```
   
   Add this import at the top:
   ```nix
   imports = [
     ./hardware-configuration.nix
     ../../modules/desktop
   ];
   ```
   
   Update these settings:
   - `networking.hostName` - Your desired hostname
   - `time.timeZone` - Your timezone
   - `users.users.user.name` - Change "user" to your username

5. **Edit home configuration**:
   ```bash
   nano /mnt/etc/nixos/home/desktop.nix
   ```
   
   Update:
   - `home.username` - Your username
   - `home.homeDirectory` - Your home directory path
   - `programs.git.userName` and `programs.git.userEmail`

6. **Update flake.nix**:
   ```bash
   nano /mnt/etc/nixos/flake.nix
   ```
   
   Change all instances of `user` to your username in the home-manager configuration.

7. **Install**:
   ```bash
   nixos-install --flake /mnt/etc/nixos#desktop
   ```

8. **Reboot**:
   ```bash
   reboot
   ```

9. **Login and enjoy!**
   - At the login prompt, press Enter for a TUI to select Hyprland
   - Login with your user credentials
   - Press `SUPER + Return` to open a terminal
   - Press `SUPER + D` to open the application launcher

### Server Installation

Follow similar steps but use:
- `hosts/server/configuration.nix` instead of desktop
- `home/server.nix` instead of desktop
- `--flake /mnt/etc/nixos#server` for installation
- Remember to add your SSH public keys to the configuration!

## Installation with Home Manager (Non-NixOS)

### On Ubuntu/Debian/Fedora/Other Linux

1. **Install Nix**:
   ```bash
   sh <(curl -L https://nixos.org/nix/install) --daemon
   ```

2. **Enable flakes**:
   ```bash
   mkdir -p ~/.config/nix
   echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
   ```

3. **Restart your shell or reboot**

4. **Clone configuration**:
   ```bash
   git clone https://github.com/j0fr3y/nix-config ~/.config/nix-config
   cd ~/.config/nix-config
   ```

5. **Edit home configuration**:
   ```bash
   nano home/desktop.nix
   ```
   
   Update your username and git settings.

6. **Apply configuration**:
   ```bash
   nix run home-manager/master -- switch --flake .#user@desktop
   ```

7. **For future updates**:
   ```bash
   home-manager switch --flake ~/.config/nix-config#user@desktop
   ```

## First Steps After Installation

### Desktop

1. **Learn the keybindings** (see README.md)
   - `SUPER + Return` - Terminal
   - `SUPER + D` - App launcher
   - `SUPER + E` - File manager
   - `SUPER + Q` - Close window

2. **Customize Hyprland**:
   ```bash
   nano ~/.config/hypr/hyprland.conf
   # Or edit home/config/hypr/hyprland.conf and rebuild
   ```

3. **Install additional software**:
   - Edit `home/desktop.nix` to add packages to `home.packages`
   - Rebuild: `home-manager switch --flake ~/.config/nix-config#user@desktop`

4. **Set up Git**:
   - Configure your git credentials in `home/desktop.nix`
   - Rebuild to apply

### Server

1. **SSH access**:
   - Add your SSH keys to `hosts/server/configuration.nix`
   - Rebuild and then you can SSH in

2. **Configure services**:
   - Edit `modules/server/default.nix` to add services
   - Rebuild with `sudo nixos-rebuild switch --flake .#server`

## Common Customizations

### Change Window Manager Theme

Edit `home/config/hypr/hyprland.conf`:
```
col.active_border = rgba(ff5555ee) rgba(ff79c6ee) 45deg
```

### Add More Applications

In `home/desktop.nix`, add to `home.packages`:
```nix
home.packages = with pkgs; [
  # ... existing packages ...
  discord
  telegram-desktop
  gimp
  inkscape
];
```

### Change Terminal

Replace `kitty` in `modules/desktop/wayland.nix` with your preferred terminal:
```nix
alacritty  # or
wezterm    # or
foot       # etc
```

Also update the keybinding in `home/config/hypr/hyprland.conf`:
```
bind = $mainMod, Return, exec, alacritty
```

### Use Different Compositor

Instead of Hyprland, you can use Sway:

In `modules/desktop/wayland.nix`:
```nix
programs.sway = {
  enable = true;
  wrapperFeatures.gtk = true;
};
```

## Troubleshooting

### Build fails
```bash
# Check what's wrong
nix flake check --show-trace

# Often it's just a typo in configuration
```

### Can't login after installation
- Check if username is correct
- Password might not be set - boot into rescue mode to set it:
  ```bash
  passwd yourusername
  ```

### Applications don't start
- Check logs: `journalctl -xe`
- Hyprland logs: `~/.local/share/hyprland/hyprland.log`

### Need to rollback
- At boot, select previous generation
- Or: `sudo nixos-rebuild switch --rollback`

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Nix Package Search](https://search.nixos.org/)

## Getting Help

- NixOS Discourse: https://discourse.nixos.org/
- NixOS Wiki: https://nixos.wiki/
- Hyprland Discord: https://discord.gg/hQ9XvMUjjr
