{ pkgs, lib, config, ... }:

let
  btHeadphonesMac = "74:45:CE:E0:CA:A4";
in
{
  options = {
    waybar.enable = lib.mkEnableOption "enables Waybar status bar";
  };

  config = lib.mkIf config.waybar.enable {
    home.packages = with pkgs; [ bluez playerctl btop ];

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
          fixed-center = false;
          modules-left = [ "sway/workspaces" "sway/mode" ];
          modules-center = [ "sway/window" "custom/sep" "clock#date" ];
          modules-right = [ "pulseaudio" "network" "cpu" "memory" "temperature" "backlight" "battery" "clock#time" "tray" ];

          "clock#date" = {
            format = "{:%u%d}";
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
            format = "{}";
            max-length = 50;
            rewrite = {
              "(.*) - Brave" = "🌎 $1";
              ".*[Oo]bsidian.*" = "📝 Notes";
            };
          };

          "custom/sep" = {
            format = " | ";
          };

          "pulseaudio" = {
            format = "v: {volume}%";
            format-muted = "v: MUTED";
            format-icons = {
              headphone = "";
              default = ["false" "true"];
            };
            tooltip-format = "Volume: {volume}%\nSink: {desc}";
            on-click = "${pkgs.bluez}/bin/bluetoothctl connect ${btHeadphonesMac}";
            on-click-right = "${pkgs.bluez}/bin/bluetoothctl disconnect ${btHeadphonesMac}";
            on-click-middle = "${pkgs.playerctl}/bin/playerctl play-pause";
            on-scroll-up = "${pkgs.playerctl}/bin/playerctl position 5+";
            on-scroll-down = "${pkgs.playerctl}/bin/playerctl position 5-";
          };

          "network" = {
            format-wifi = "n: {ipaddr}/{cidr}";
            format-ethernet = "n: {ipaddr}/{cidr}";
            format-disconnected = "n: OFFLINE";
            tooltip-format-wifi = "{essid}\nSignal: {signalStrength}%\nFreq: {frequency}GHz\nIP: {ipaddr}\nGateway: {gwaddr}";
            tooltip-format-ethernet = "{ifname}\nIP: {ipaddr}/{cidr}\nGateway: {gwaddr}";
            format-icons = {
              wifi = "";
              ethernet = "";
            };
          };

          "cpu" = {
            format = "c: {icon0}{icon1}{icon2}{icon3}{icon4}{icon5}{icon6}{icon7}";
            format-icons = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
            on-click = "${pkgs.ghostty}/bin/ghostty -e ${pkgs.btop}/bin/btop --preset 2 --update 100";
          };

          "memory" = {
            format = "m: {percentage}%";
            tooltip-format = "{used:0.1f}GB / {total:0.1f}GB\nAvailable: {avail:0.1f}GB";
          };

          "temperature" = {
            critical-threshold = 80;
            format = "t: {temperatureC}°C";
            hwmon-path = [
              "/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon0/temp1_input"
              "/sys/devices/platform/thinkpad_hwmon/hwmon/hwmon3/temp1_input"
              "/sys/devices/platform/thinkpad_hwmon/hwmon/hwmon3/temp2_input"
              "/sys/devices/platform/thinkpad_hwmon/hwmon/hwmon3/temp3_input"
              "/sys/devices/platform/thinkpad_hwmon/hwmon/hwmon3/temp4_input"
              "/sys/devices/platform/thinkpad_hwmon/hwmon/hwmon3/temp5_input"
              "/sys/devices/platform/thinkpad_hwmon/hwmon/hwmon3/temp6_input"
              "/sys/devices/platform/thinkpad_hwmon/hwmon/hwmon3/temp7_input"
              "/sys/devices/platform/thinkpad_hwmon/hwmon/hwmon3/temp8_input"
              "/sys/devices/pci0000:00/0000:00:08.1/0000:04:00.0/hwmon/hwmon4/temp1_input"
            ];
          };

          "backlight" = {
            format = "l: {percent}%";
            # format-icons = [ "" "" "" "" "" ];
            on-click-middle = "systemctl hibernate";
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
            format = "t: {:%H%M}";
	    tooltip = false;
            interval = 60;
            timezones = [ "" "Europe/Amsterdam" ];
            actions = {
              on-click-right = "mode";
              on-scroll-up = "tz_up";
              on-scroll-down = "tz_down";
            };
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

        #custom-sep {
          background: transparent;
          color: #00ff00;
          padding: 0;
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
