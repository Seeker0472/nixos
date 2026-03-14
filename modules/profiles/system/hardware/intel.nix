{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf (config.machine.cpu == "intel") {
    #HardWare AccelerationConfig
    #https://nixos.wiki/wiki/Accelerated_Video_Playback
    hardware.graphics = {
      # hardware.graphics on unstable
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        vpl-gpu-rt # for newer GPUs on NixOS >24.05 or unstable;
        intel-compute-runtime
      ];
    };
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "iHD";
    };
  };
}
