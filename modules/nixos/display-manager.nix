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
        animation = "cmatrix";
        hide_borders = true;
        clock = "%H%M";
        bigclock = true;
        hide_f1_commands = true;
      };
    };
  };
}