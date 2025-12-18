{ pkgs, lib, config, ... }:

{
  options = {
    steam.enable =
      lib.mkEnableOption "enables Steam gaming platform";
  };

  config = lib.mkIf config.steam.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [ mesa ];
      extraPackages32 = with pkgs; [ pkgsi686Linux.mesa ];
    };

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    environment.systemPackages = with pkgs; [
      brightnessctl
    ];
  };
}