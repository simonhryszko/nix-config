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
        animation = "gameoflife";
      };
    };
  };
}