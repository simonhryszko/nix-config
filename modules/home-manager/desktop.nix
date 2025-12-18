{ pkgs, lib, config, ... }:

{
  options = {
    desktop.enable = lib.mkEnableOption "enables desktop environment services";
  };

  config = lib.mkIf config.desktop.enable {
    services.syncthing = {
      enable = true;
      tray.enable = true;
      guiAddress = "127.0.0.1:8384";
    };

    services.kdeconnect = {
      enable = true;
      indicator = true;
    };

    services.copyq = {
      enable = true;
      systemdTarget = "sway-session.target";
      forceXWayland = false;
    };

    xdg.configFile."copyq/copyq.conf".text = ''
      [Options]
      maxitems=2000
      move=true
      check_clipboard=true
      copy_selection=false
      close_on_unfocus=true
      hide_main_window=true
      hide_tabs=false
      hide_toolbar=false
      hide_toolbar_labels=true
      show_simple_items=false
      confirm_exit=false
      style=Fusion
      transparency=10
      transparency_focused=0
      frameless_window=false
      always_on_top=false
      window_width=600
      window_height=400
      window_geometry=600x400+100+100
      theme=dark
      font_family=monospace
      font_size=11
      item_popup_interval=0
      clipboard_notification_lines=0
      disable_tray=false
      tray_items=5
      tray_images=true
      tray_commands=true
      native_notifications=false
      autocompletion=true
      filter_case_insensitive=true
      number_search=false
      text_wrap=true
      save_on_app_deactivated=true
      restore_geometry=true
      open_windows_on_current_screen=true
    '';
  };
}