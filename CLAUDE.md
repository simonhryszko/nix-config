# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NixOS + Home Manager flake-based configuration for a single-user system (host: e495, user: simon). The configuration uses a modular architecture with reusable NixOS and Home Manager modules.

## Architecture

### Structure
```
flake.nix                    # Entrypoint: defines outputs, inputs, and module exports
hosts/e495/                  # Host-specific system configuration
  configuration.nix          # System-level NixOS config (boot, networking, users)
  hardware-configuration.nix # Auto-generated hardware settings
home.nix                     # Home Manager entrypoint (user-level config)
modules/
  nixos/                     # System-level reusable modules (audio, sway, steam, etc.)
    default.nix              # NixOS module aggregator
  home-manager/              # User-level reusable modules (shell, desktop, sway config, etc.)
    default.nix              # Home Manager module aggregator
```

### Module Pattern
All modules follow a consistent pattern:
1. Define an enable option using `lib.mkEnableOption`
2. Use `lib.mkIf config.<module>.enable` to conditionally apply configuration
3. Enable modules in `configuration.nix` (system) or `home.nix` (user) by setting `<module>.enable = true;`

Example:
```nix
# modules/home-manager/common.nix
options = {
  common.enable = lib.mkEnableOption "enables common user programs and tools";
};
config = lib.mkIf config.common.enable { ... };
```

### Key Distinction
- **NixOS modules** (`modules/nixos/`): System-level configuration (boot, networking, services, firewall). Imported in `hosts/e495/configuration.nix`.
- **Home Manager modules** (`modules/home-manager/`): User-level configuration (packages, shell, dotfiles, WM user config). Imported via `home.nix`.

## Build Commands

**System rebuild (NixOS configuration changes):**
```bash
sudo nixos-rebuild switch --flake ~/.config/nix-config#e495
```
Shell alias: `rebuild`

**User rebuild (Home Manager only changes):**
```bash
home-manager switch --flake ~/.config/nix-config
```
Shell alias: `hm switch`

**Update flake inputs:**
```bash
nix flake update ~/.config/nix-config
```
Shell alias: `update`

**Garbage collection:**
```bash
nix-collect-garbage -d
```
Shell alias: `clean`

## Development Practices

- Before updating config: `man home-configuration.nix | grep -A10 -B5 -i <phase>` or `man configuration.nix | grep <option>`
- Check actual configuration for real examples before explaining
- Never use 'probably' or similar words - verify or state you cannot tell
- Use `man` pages, config file comments, and `--help` instead of web search

## Keybinding Notation
- `^` = Ctrl key
- `mod` = Super key
- `modv`, `modg`, `mode` = Super key + respective letter key
- `^modv` = Ctrl + Super + V together

## Git Workflow
When making commits, ask if the changes work as intended. If confirmed:
```bash
git add .. && git commit -m '<message>'
```
When all changes are committed, suggest push.

## Shell Configuration
Zsh is heavily customized in `modules/home-manager/development.nix` with:
- Aliases for common operations (ls → eza, find → fd, grep → rg, etc.)
- Directory hashes: `~nixpkgs`, `~hm` (points to this repo), `~docs`, `~dld`
- Custom prompt with git branch, exit status, and time
- FZF integration with fd for file finding