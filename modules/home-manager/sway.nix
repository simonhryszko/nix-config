{ pkgs, lib, config, ... }:

{
  options = {
    sway.enable =
      lib.mkEnableOption "enables Sway Home Manager configuration";
  };

  config = lib.mkIf config.sway.enable {
    wayland.windowManager.sway = {
      enable = true;
      systemd.enable = true;
      config = {
        modifier = "Mod4";
        terminal = "ghostty";

        gaps = {
          inner = 2;
          outer = 0;
        };

        window.border = 1;

        input = {
          "type:touchpad" = {
            tap = "enabled";
            dwt = "enabled";
          };
        };

        bars = [ ];

        floating.criteria = [
          { app_id = "copyq"; }
          { class = "CopyQ"; }
          { title = "CopyQ"; }
          { class = "com-atlauncher-App"; }
          { app_id = "brave-nngceckbapebfimnlniiiahkandclblb-Default"; }
          { title = "Picture-in-picture"; }
          { title = "btop"; }
          { app_id = "pavucontrol"; }
          { window_role = "pop-up"; }
          { window_role = "bubble"; }
          { window_role = "task_dialog"; }
          { window_role = "Preferences"; }
          { window_type = "dialog"; }
          { window_type = "menu"; }
          { window_role = "About"; }
          { title = "File Operation Progress"; }
          { title = "waybar_htop"; }
          { title = "waybar_nmtui"; }
          { title = "Save File"; }
          # { app_id = ""; }
        ];

        keybindings = let
          modifier = config.wayland.windowManager.sway.config.modifier;
        in lib.mkOptionDefault {
          "${modifier}+q" = "kill";
          "${modifier}+Ctrl+v" = "exec copyq toggle";

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

          "${modifier}+Ctrl+Left" = "exec swaymsg workspace prev";
          "${modifier}+Ctrl+Right" = "exec swaymsg workspace next";
          "${modifier}+Ctrl+h" = "exec swaymsg workspace prev";
          "${modifier}+Ctrl+l" = "exec swaymsg workspace next";

          "${modifier}+l" = "exec ${pkgs.swaylock}/bin/swaylock -c $(printf \"%06x\" $(shuf -i 0-16777215 -n 1))";

          "XF86AudioRaiseVolume" = "exec pamixer --increase 5";
          "XF86AudioLowerVolume" = "exec pamixer --decrease 5";
          "XF86AudioMute" = "exec pamixer --toggle-mute";
          "XF86AudioMicMute" = "exec pamixer --toggle-mute --default-source";
          "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
          "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";

          "${modifier}+Ctrl+Alt+space" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
          "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
          "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";

          "${modifier}+Shift+minus" = "move scratchpad";
          "${modifier}+minus" = "scratchpad show";

          "Alt+Shift+s" = "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.swappy}/bin/swappy -f -";
          "Alt+Ctrl+Shift+s" = "exec power-menu";
        };

        startup = [
          { command = "autotiling"; }
          { command = "mako"; }
        ];
      };
    };

    home.packages = with pkgs; [
      autotiling
      grim
      slurp
      swappy
      mako
      swaylock
      (pkgs.writeShellScriptBin "power-menu" ''
        echo -e 'Lock\nSuspend\nHibernate\nRestart\nShutdown' | ${pkgs.fuzzel}/bin/fuzzel --dmenu -p 'Power:' | ${pkgs.bash}/bin/bash -c 'case $(cat) in Lock) ${pkgs.swaylock}/bin/swaylock -c $(printf "%06x" $(shuf -i 0-16777215 -n 1)) ;; Suspend) ${pkgs.systemd}/bin/systemctl suspend ;; Hibernate) ${pkgs.systemd}/bin/systemctl hibernate ;; Restart) ${pkgs.systemd}/bin/systemctl reboot ;; Shutdown) ${pkgs.systemd}/bin/systemctl poweroff ;; esac'
      '')
      (pkgs.writeShellScriptBin "sway-workspace-switcher" ''
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

        if [[ -z "$WORKSTATION_ID" ]]; then
          logger -t "sway-workspace-switcher" "Error: No workspace ID provided"
          exit 1
        fi

        append_to_history "$CURRENT_WS"

        if [[ "$WORKSTATION_ID" == "$CURRENT_WS" ]]; then
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

        if swaymsg workspace "$WORKSTATION_ID" >/dev/null 2>&1; then
          logger -t "sway-workspace-switcher" "Successfully switched to workspace $WORKSTATION_ID"
          append_to_history "$WORKSTATION_ID"
        else
          logger -t "sway-workspace-switcher" "Error: Failed to switch to workspace $WORKSTATION_ID"
          exit 1
        fi
      '')
    ];
  };
}
