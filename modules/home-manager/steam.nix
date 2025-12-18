{ pkgs, lib, config, ... }:

{
  options = {
    steam.enable = lib.mkEnableOption "enables Steam gaming platform";
  };

  config = lib.mkIf config.steam.enable {
    home.packages = with pkgs; [
      steam
    ];
  };
}