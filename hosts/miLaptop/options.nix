{ lib, ... }:
let
  homeHost = import ./home.nix;
in
{
  # TODO: default option not work!
  config.machine = lib.recursiveUpdate homeHost.machine {
    cpu = "intel";
    impermanence.enable = true;
    programs = {
      mihomo = {
        enable = true;
        tun.enable = true;
      };
      thunar.enable = true;
      steam.enable = true;
      tailscale.enable = true;
    };
    secrets = {
      webdav.enable = true;
    };
    virtualization = {
      docker.enable = true;
      virtualbox.enable = true;
    };
  };
}
