{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "simon";
  home.homeDirectory = "/home/simon";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # Add this to allow unfree packages in Home Manager
  nixpkgs.config.allowUnfree = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    pkgs.brave
    pkgs.claude-code
    pkgs.youtube-tui
    pkgs.mpv
    pkgs.obsidian
    pkgs.ranger
    pkgs.steam
    # pkgs.git
    pkgs.wl-clipboard
    pkgs.lazygit
    pkgs.btop
    pkgs.yq-go
    pkgs.ghostty
    pkgs.jq
    pkgs.pamixer
    pkgs.gh

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    (pkgs.writeShellScriptBin "hmManOptions" ''
      man home-configuration.nix | grep -iE "programs.*$1" | grep -vE "<home| {8}" | tr -d ' '
    '')

    (pkgs.writeShellScriptBin "sway-workspace-switcher" ''
      # Sway workspace switcher with back-and-forth functionality like in i3wm
      # Usage: sway-workspace-switcher <WORKSPACE_ID>

      SWAY_WORKSTATION_HISTORY=''${SWAY_WORKSTATION_HISTORY:-/tmp/sway_workstation_history}
      WORKSTATION_ID=$1
      CURRENT_WS=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused==true) | .num')

      append_to_history() {
        local ws=$1
        local last_entry=$(tail -1 "$SWAY_WORKSTATION_HISTORY" 2>/dev/null)
        if [[ "$ws" != "$last_entry" ]]; then
          echo "$ws" >>"$SWAY_WORKSTATION_HISTORY"
        fi
      }

      # Check if workspace ID was provided
      if [[ -z "$WORKSTATION_ID" ]]; then
        logger -t "sway-workspace-switcher" "Error: No workspace ID provided"
        exit 1
      fi

      # Ensure current workspace is in history before switching
      append_to_history "$CURRENT_WS"

      # If requested workspace is the current one, go to previous workspace
      if [[ "$WORKSTATION_ID" == "$CURRENT_WS" ]]; then
        # Get second to last workspace from history (previous workspace)
        PREVIOUS_WS=$(tail -2 "$SWAY_WORKSTATION_HISTORY" 2>/dev/null | head -1)
        if [[ -n "$PREVIOUS_WS" && "$PREVIOUS_WS" != "$CURRENT_WS" ]]; then
          WORKSTATION_ID="$PREVIOUS_WS"
          logger -t "sway-workspace-switcher" "Switching back to workspace $WORKSTATION_ID"
        else
          logger -t "sway-workspace-switcher" "No previous workspace found or same as current"
          exit 1
        fi
      else
        logger -t "sway-workspace-switcher" "Switching to workspace $WORKSTATION_ID"
      fi

      # Switch to the workspace
      if swaymsg workspace "$WORKSTATION_ID" >/dev/null 2>&1; then
        # Append current workspace to history (before the switch)
        logger -t "sway-workspace-switcher" "Successfully switched to workspace $WORKSTATION_ID"
        append_to_history "$WORKSTATION_ID"
      else
        logger -t "sway-workspace-switcher" "Error: Failed to switch to workspace $WORKSTATION_ID"
        exit 1
      fi
    '')

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/simon/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    SHELL = "${pkgs.zsh}/bin/zsh";
  };

	programs.zsh = {
	  enable = true;
	  shellAliases.ll = "ls -la";
	  initContent = "source ~/.env &>>/tmp/zsh_env.logs";
	};

  # Git configuration
  programs.git = {
    enable = true;
    settings.user = {
      name = "Simon Hryszko";
      email = "simonhryszko@gmail.com";
    };
  };

  # Syncthing service
  services.syncthing = {
    enable = true;
    tray.enable = true;
    guiAddress = "127.0.0.1:8384";
  };

  # CopyQ clipboard manager
  services.copyq = {
    enable = true;
    systemdTarget = "sway-session.target";
    forceXWayland = false;  # Native Wayland support
  };

  # Sway window manager configuration
  wayland.windowManager.sway = {
    enable = true;
    systemd.enable = true;
    config = {
      modifier = "Mod4";
      terminal = "ghostty";

      # Input configuration for touchpad tap-to-click
      input = {
        "type:touchpad" = {
          tap = "enabled";
        };
      };

      # Disable default Sway bar (using Waybar instead)
      bars = [ ];

      keybindings = let
        modifier = config.wayland.windowManager.sway.config.modifier;
      in lib.mkOptionDefault {
        "${modifier}+q" = "kill";
        "${modifier}+Shift+v" = "exec copyq toggle";

        # Custom workspace switcher with back-and-forth functionality
        "${modifier}+1" = "exec sway-workspace-switcher 1";
        "${modifier}+2" = "exec sway-workspace-switcher 2";
        "${modifier}+3" = "exec sway-workspace-switcher 3";
        "${modifier}+4" = "exec sway-workspace-switcher 4";
        "${modifier}+5" = "exec sway-workspace-switcher 5";
        "${modifier}+6" = "exec sway-workspace-switcher 6";
        "${modifier}+7" = "exec sway-workspace-switcher 7";
        "${modifier}+8" = "exec sway-workspace-switcher 8";
        "${modifier}+9" = "exec sway-workspace-switcher 9";
        "${modifier}+0" = "exec sway-workspace-switcher 10";

        # Move window to workspace and change workspace (mod + shift + workspace_id)
        "${modifier}+Shift+1" = "move container to workspace 1, exec sway-workspace-switcher 1";
        "${modifier}+Shift+2" = "move container to workspace 2, exec sway-workspace-switcher 2";
        "${modifier}+Shift+3" = "move container to workspace 3, exec sway-workspace-switcher 3";
        "${modifier}+Shift+4" = "move container to workspace 4, exec sway-workspace-switcher 4";
        "${modifier}+Shift+5" = "move container to workspace 5, exec sway-workspace-switcher 5";
        "${modifier}+Shift+6" = "move container to workspace 6, exec sway-workspace-switcher 6";
        "${modifier}+Shift+7" = "move container to workspace 7, exec sway-workspace-switcher 7";
        "${modifier}+Shift+8" = "move container to workspace 8, exec sway-workspace-switcher 8";
        "${modifier}+Shift+9" = "move container to workspace 9, exec sway-workspace-switcher 9";
        "${modifier}+Shift+0" = "move container to workspace 10, exec sway-workspace-switcher 10";

        # Move window to workspace without switching (mod + ctrl + workspace_id)
        "${modifier}+Ctrl+1" = "move container to workspace 1";
        "${modifier}+Ctrl+2" = "move container to workspace 2";
        "${modifier}+Ctrl+3" = "move container to workspace 3";
        "${modifier}+Ctrl+4" = "move container to workspace 4";
        "${modifier}+Ctrl+5" = "move container to workspace 5";
        "${modifier}+Ctrl+6" = "move container to workspace 6";
        "${modifier}+Ctrl+7" = "move container to workspace 7";
        "${modifier}+Ctrl+8" = "move container to workspace 8";
        "${modifier}+Ctrl+9" = "move container to workspace 9";
        "${modifier}+Ctrl+0" = "move container to workspace 10";
        # Navigate to previous/next workspace (mod + ctrl + arrow keys)
        "${modifier}+Ctrl+Left" = "exec swaymsg workspace prev";
        "${modifier}+Ctrl+Right" = "exec swaymsg workspace next";

        # Multimedia keys for volume and brightness control
        "XF86AudioRaiseVolume" = "exec pamixer --increase 5";
        "XF86AudioLowerVolume" = "exec pamixer --decrease 5";
        "XF86AudioMute" = "exec pamixer --toggle-mute";
        "XF86AudioMicMute" = "exec pamixer --toggle-mute --default-source";
        "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
      };
    };
  };

  # Ghostty terminal configuration
  programs.ghostty = {
    enable = true;
    settings = {
      theme = "Blue Matrix";
    };
  };

  # Waybar status bar configuration
  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = "sway-session.target";
    };
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        modules-left = [ "sway/workspaces" "sway/mode" ];
        modules-center = [ "sway/window" ];
        modules-right = [ "pulseaudio" "network" "cpu" "memory" "temperature" "backlight" "battery" "clock" "tray" ];
      };
    };
  };

  # MPV media player configuration
  programs.mpv = {
    enable = true;
    config = {
      # Save position on quit and restore on resume
      save-position-on-quit = true;

      # Keep track of watch history
      watch-later-directory = "~/.local/share/mpv/watch_later";

      # Automatically resume from where left off
      resume-playback = true;
      resume-playback-check-mtime = true;

      # Other useful settings for better experience
      keep-open = true; # Keep video open after playback ends
      keep-open-pause = true; # Pause instead of stopping at end
    };
  };

  # CopyQ configuration file
  xdg.configFile."copyq/copyq.conf".text = ''
    [General]
    max_items=2000
    move_to_front=true
    check_clipboard=true
    synchronize_clipboard=true

    [Appearance]
    theme=dark
    font_family=monospace
    font_size=12
    color_bg=#282828
    color_fg=#ebdbb2
    color_alt_bg=#3c3836
    color_alt_fg=#ebdbb2
    color_sel_bg=#458588
    color_sel_fg=#ebdbb2
    color_find_bg=#3c3836
    color_find_fg=#ebdbb2
    color_font=#ebdbb2
    color_font_selected=#ebdbb2
    color_editor_bg=#282828
    color_editor_fg=#ebdbb2

    [Commands]
    command_1=CopyQ: Copy
    copyq:copy
    input=clipboard
    output=clipboard
    shortcut=ctrl+c
    show_in_main_menu=true

    [Options]
    tray=true
    hide_main_window=true
    hide_on_close=true
    close_on_unfocus=true
    notifications=false
  '';

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
