{ pkgs, lib, config, ... }:

{
  options = {
    ghostty.enable = lib.mkEnableOption "enables Ghostty terminal emulator";
  };

  config = lib.mkIf config.ghostty.enable {
    programs.ghostty = {
      enable = true;
      settings = {
        theme = "Matrix";
        background-opacity = 0.95;
        background-blur-radius = 25;
        font-size = 12;
        cursor-style = "block";
        cursor-style-blink = true;
        cursor-invert-fg-bg = true;
        mouse-hide-while-typing = true;
        confirm-close-surface = false;
        window-decoration = true;
        window-padding-x = 10;
        window-padding-y = 10;
        window-padding-balance = true;
        shell-integration-features = "no-cursor";
        copy-on-select = "clipboard";
        keybind = [
          "ctrl+shift+p=unbind"
          "ctrl+shift+n=unbind"
          "f1=toggle_command_palette"
        ];
      };
    };
  };
}
