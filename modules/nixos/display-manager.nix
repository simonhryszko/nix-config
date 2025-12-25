{ pkgs, lib, config, ... }:

{
  options = {
    display-manager.enable =
      lib.mkEnableOption "enables Ly display manager";
  };

  config = lib.mkIf config.display-manager.enable {
    services.displayManager.ly = {
      enable = true;
      settings = {
        animate = true;
        animation = 1;
        hide_borders = true;
        hide_key_hints = true;
        bigclock = true;
      };
    };
  };
}