{ pkgs, lib, config, ... }:

{
  options = {
    minecraft.enable = lib.mkEnableOption "enables Minecraft launcher";
  };

  config = lib.mkIf config.minecraft.enable {
    home.packages = with pkgs; [
      atlauncher
    ];
  };
}