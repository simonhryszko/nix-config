{ pkgs, lib, config, ... }:

{
  options = {
    waybar.enable = lib.mkEnableOption "enables Waybar status bar";
  };

  config = lib.mkIf config.waybar.enable {
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
          modules-center = [ "sway/window" "clock#date" ];
          modules-right = [ "pulseaudio" "network" "cpu" "memory" "temperature" "backlight" "battery" "clock#time" "tray" ];

          "clock#date" = {
            format = "{:%A %d}";
            interval = 3600;
            tooltip-format = "<tt><small>{calendar}</small></tt>";
            calendar = {
              mode = "year";
              mode-mon-col = 3;
              weeks-pos = "left";
              on-scroll = 1;
              format = {
                months = "<span color='#0f0'><b>{}</b></span>";
                days = "<span color='#0f0'>{}</span>";
                weeks = "<span color='#0c0'><b>W{}</b></span>";
                weekdays = "<span color='#0c0'><b>{}</b></span>";
                today = "<span bgcolor='#006600'><span color='#0f0'><b><u>{}</u></b></span></span>";
              };
            };
            actions = {
              on-click-right = "mode";
              on-scroll-up = "shift_up";
              on-scroll-down = "shift_down";
            };
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
            format = "v: {volume}%";
            format-muted = "v: MUTED";
            format-icons = {
              headphone = "";
              default = [ "" ];
            };
          };

          "network" = {
            format-wifi = "n: {ipaddr}";
            format-ethernet = "n: {ipaddr}";
            format-disconnected = "n: OFFLINE";
            format-icons = {
              wifi = "";
              ethernet = "";
            };
          };

          "cpu" = {
            format = "c: {usage}%";
          };

          "memory" = {
            format = "m: {percentage}%";
          };

          "temperature" = {
            critical-threshold = 80;
            format = "t: {temperatureC}°C";
            hwmon-path = [ "/sys/class/hwmon/hwmon0/temp1_input" "/sys/class/hwmon/hwmon1/temp1_input" "/sys/class/hwmon/hwmon2/temp1_input" "/sys/class/hwmon/hwmon3/temp1_input" "/sys/class/hwmon/hwmon4/temp1_input" "/sys/class/hwmon/hwmon5/temp1_input" ];
          };

          "backlight" = {
            format = "l: {percent}%";
            # format-icons = [ "" "" "" "" "" ];
          };

          "battery" = {
            format = "b: {capacity}%";
            format-charging = "b: {capacity}%+";
            format-plugged = "b: {capacity}%";
            states = {
              warning = 30;
              critical = 15;
            };
          };

          "clock#time" = {
            format = "t: {:%H:%M}";
            interval = 60;
            tooltip-format = "CET: {:%H:%M}";
          };

          "tray" = {
            spacing = 2;
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
          padding: 2px 8px;
          margin: 2px;
          text-shadow: 0 0 3px #00ff00;
        }

        #workspaces button.active {
          background: transparent;
          font-weight: bold;
          color: #00ff00;
          text-shadow: 0 0 5px #00ff00;
        }

        #workspaces button.focused {
          background: transparent;
          text-shadow: 0 0 5px #00ff00;
        }

        #workspaces button.urgent {
          background: transparent;
          text-shadow: 0 0 8px #00ff00;
        }

        #window {
          background: transparent;
          color: #00ff00;
          text-shadow: 0 0 3px #00ff00;
          padding: 0 10px;
        }

        #mode {
          background: transparent;
          color: #00ff00;
          text-shadow: 0 0 3px #00ff00;
          padding: 0 10px;
        }

        #pulseaudio, #network, #cpu, #memory, #temperature, #backlight, #battery, #clock.time, #tray {
          background: transparent;
          color: #00ff00;
          padding: 0 5px;
          margin: 0;
          border-left: 1px solid #00ff00;
          text-shadow: 0 0 3px #00ff00;
        }

        #temperature.critical {
          background: #ff0000;
        }


        #battery.warning:not(.charging) {
          background: #ffaa00;
          color: #000000;
        }

        #battery.critical:not(.charging) {
          background: #ff0000;
        }

        #clock {
          text-shadow: 0 0 5px #00ff00;
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
  };
}
