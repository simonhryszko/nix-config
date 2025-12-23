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
          modules-center = [ "sway/window" "custom/date" ];
          modules-right = [ "pulseaudio" "network" "cpu" "memory" "temperature" "backlight" "battery" "clock" "tray" ];

          "custom/date" = {
            format = "{}";
            exec = "date '+%A %d'";
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
            format-wifi = "n: {ipaddr} ";
            format-ethernet = "n: {ipaddr} ";
            format-disconnected = "n: OFFLINE ";
            format-icons = {
              wifi = "";
              ethernet = "";
            };
          };

          "cpu" = {
            format = "c: {usage}% ";
          };

          "memory" = {
            format = "m: {percentage}% ";
          };

          "temperature" = {
            format = "t: {temperatureC}°C ";
            critical-threshold = 80;
          };

          "backlight" = {
            format = "b: {percent}% ";
            # format-icons = [ "" "" "" "" "" ];
          };

          "battery" = {
            format = "b: {capacity}% ";
            format-charging = "b: {capacity}%+ ";
            format-plugged = "b: {capacity}% ";
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
            spacing = 5;
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
  };
}
