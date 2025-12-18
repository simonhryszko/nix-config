{ pkgs, lib, config, ... }:

{
  options = {
    power-management.enable =
      lib.mkEnableOption "enables power management services";
  };

  config = lib.mkIf config.power-management.enable {
    services.acpid.enable = true;

    services.logind.settings = {
      Login = {
        HandleLidSwitch = "hibernate";
        HandleLidSwitchDocked = "ignore";
        HandleLidSwitchExternalPower = "ignore";
      };
    };

    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;

    environment.systemPackages = with pkgs; [
      brightnessctl
    ];

    systemd.sleep.extraConfig = ''
      HibernateMode=shutdown
      HibernateDelaySec=2h
    '';
  };
}