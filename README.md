# NixOS + Home Manager Configuration

Single-user NixOS system with Home Manager for declarative package and dotfile management.

## Structure

- `configuration.nix` - System-wide NixOS settings
- `home.nix` - User-specific Home Manager settings
- `flake.nix` - Flake configuration
- `hardware-configuration.nix` - Hardware-specific settings

## Rebuild Commands

**System-wide changes:**
```bash
sudo nixos-rebuild switch --flake ~/.config/home-manager
```

**User-specific changes:**
```bash
home-manager switch --flake ~/.config/home-manager
```
