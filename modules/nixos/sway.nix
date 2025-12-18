{ pkgs, lib, config, ... }:

{
  options = {
    sway.enable =
      lib.mkEnableOption "enables Sway window manager";
  };

  config = lib.mkIf config.sway.enable {
    # Enable Sway window manager
    programs.sway.enable = true;

    # List packages installed in system profile for Sway
    environment.systemPackages = with pkgs; [
      # XDG Desktop Portal packages for KDE Connect remote input
      xdg-desktop-portal
      kdePackages.xdg-desktop-portal-kde
      xdg-desktop-portal-wlr
    ];

    # XDG Desktop Portal configuration for KDE Connect remote input
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
      configPackages = [ pkgs.sway ];
      config = {
        sway = {
          default = lib.mkForce "wlr";
          "org.freedesktop.impl.portal.ScreenCast" = "wlr";
          "org.freedesktop.impl.portal.Screenshot" = "wlr";
          "org.freedesktop.impl.portal.RemoteDesktop" = "wlr";
        };
      };
    };
  };
}