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

        input = {
          "type:touchpad" = {
            tap = "enabled";
          };
        };

        bars = [ ];

        floating.criteria = [
          { app_id = "copyq"; }
          { class = "CopyQ"; }
          { title = "CopyQ"; }
          { class = "com-atlauncher-App"; }
          { app_id = "brave-nngceckbapebfimnlniiiahkandclblb-Default"; }
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

          "XF86AudioRaiseVolume" = "exec pamixer --increase 5";
          "XF86AudioLowerVolume" = "exec pamixer --decrease 5";
          "XF86AudioMute" = "exec pamixer --toggle-mute";
          "XF86AudioMicMute" = "exec pamixer --toggle-mute --default-source";
          "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
          "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
        };
      };
    };

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
          height = 20;
          spacing = 0;
          modules-left = [ "sway/workspaces" "sway/mode" ];
          modules-center = [ "custom/date" ];
          modules-right = [ "custom/volume-separator" "pulseaudio" "network" "cpu" "memory" "temperature" "backlight" "battery" "clock" "tray" ];
          "custom/volume-separator" = {
            format = " | ";
            padding = 0;
            margin = 0;
          };

          "custom/date" = {
            format = "{%A %d}";
            interval = 3600;
          };

          "sway/workspaces" = {
            format = "{name}";
            format-icons = {
              urgent = "";
              active = "";
              default = "";
            };
          };

          "sway/window" = {
            format = "{class}";
            max-length = 50;
          };

          "pulseaudio" = {
            format = "v: {volume}% ";
            format-muted = "v: MUTED ";
            format-icons = {
              headphone = "";
              default = [ "" ];
            };
          };

          "network" = {
            format-wifi = "net: {ipaddr} ";
            format-ethernet = "net: {ipaddr} ";
            format-disconnected = "net: OFFLINE ";
            format-icons = {
              wifi = "";
              ethernet = "";
            };
          };

          "cpu" = {
            format = "cpu: {usage}% ";
          };

          "memory" = {
            format = "mem: {percentage}% ";
          };

          "temperature" = {
            format = "temp: {temperatureC}°C ";
            critical-threshold = 80;
          };

          "backlight" = {
            format = "bright: {percent}% ";
            format-icons = [ "" "" "" "" "" ];
          };

          "battery" = {
            format = "bat: {capacity}% ";
            format-charging = "bat: {capacity}%+ ";
            format-plugged = "bat: {capacity}% ";
            states = {
              warning = 30;
              critical = 15;
            };
          };

          "clock" = {
            format = "t: {%H%M} ";
            interval = 60;
          };

          "tray" = {
            spacing = 10;
          };
        };
      };

      style = ''
        * {
          font-family: "JetBrains Mono", "Fira Code", "monospace";
          font-size: 12px;
          border: none;
          border-radius: 0;
          min-height: 0;
        }

        window#waybar {
          background: rgba(0, 0, 0, 0.9);
          color: #00ff00;
          border-bottom: 1px solid #00ff00;
          box-shadow: 0 2px 0 #00ff00;
        }

        #workspaces {
          background: #000000;
          margin: 0;
          padding: 0 10px;
        }

        #workspaces button {
          background: transparent;
          color: #00ff00;
          border: none;
          padding: 2px 8px;
          margin: 2px;
          text-shadow: 0 0 3px #00ff00;
        }

        #workspaces button.active {
          background: transparent;
          color: #00ff00;
          border-bottom: 1px solid #00ff00;
          text-shadow: 0 0 5px #00ff00;
        }

        #workspaces button.focused {
          background: transparent;
          color: #00ff00;
          border-bottom: 1px solid #00ff00;
          text-shadow: 0 0 5px #00ff00;
        }

        #workspaces button.urgent {
          background: transparent;
          color: #00ff00;
          font-weight: bold;
          text-shadow: 0 0 8px #00ff00;
        }

        #window {
          background: transparent;
          color: #00ff00;
          text-shadow: 0 0 3px #00ff00;
          padding: 0 10px;
        }

        #custom-date {
          background: transparent;
          color: #00ff00;
          text-shadow: 0 0 3px #00ff00;
          padding: 0 10px;
        }

        #pulseaudio, #network, #cpu, #memory, #temperature, #backlight, #battery, #clock {
          background: transparent;
          color: #00ff00;
          padding: 0 8px;
          margin: 0;
          border-left: 1px solid #00ff00;
          text-shadow: 0 0 3px #00ff00;
        }

        #pulseaudio {
          border-left: none;
        }

        #network {
          color: #00ff00;
        }

        #cpu {
          color: #00ff00;
        }

        #memory {
          color: #00ff00;
        }

        #temperature.critical {
          background: #ff0000;
          color: #00ff00;
        }

        #backlight {
          color: #00ff00;
        }

        #battery.charging {
          color: #00ff00;
        }

        #battery.warning:not(.charging) {
          background: #ffaa00;
          color: #000000;
        }

        #battery.critical:not(.charging) {
          background: #ff0000;
          color: #00ff00;
        }

        #clock {
          color: #00ff00;
          text-shadow: 0 0 5px #00ff00;
        }

        #tray {
          background: transparent;
          padding: 0 10px 0 0;
        }

        .modules-left > widget:first-child {
          border-left: none;
        }

        .modules-right > widget:last-child {
          border-right: none;
        }

        @keyframes blink {
          to {
            background-color: #00ff00;
            color: #000000;
          }
        }

        #battery.critical:not(.charging) {
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }
      '';
    };

    home.packages = with pkgs; [
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
