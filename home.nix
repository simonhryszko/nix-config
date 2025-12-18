{ config, pkgs, lib, inputs, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.11";

  # Enable core functionality modules
  common.enable = true;
  development.enable = true;
  desktop.enable = true;

  # Enable gaming modules
  steam.enable = true;
  minecraft.enable = true;

  # Enable window manager module
  sway.enable = true;

  programs.home-manager.enable = true;
}