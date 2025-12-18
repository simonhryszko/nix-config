{ pkgs, lib, config, ... }:

{
  options = {
    audio.enable =
      lib.mkEnableOption "enables PipeWire audio service";
  };

  config = lib.mkIf config.audio.enable {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };
  };
}