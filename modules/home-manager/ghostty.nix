{ pkgs, lib, config, ... }:

{
  options = {
    ghostty.enable = lib.mkEnableOption "enables Ghostty terminal emulator";
  };

  config = lib.mkIf config.ghostty.enable {
    programs.ghostty = {
      enable = true;
      settings = {
        theme = "Blue Matrix";
        copy-on-select = "clipboard";
      };
    };
  };
}
