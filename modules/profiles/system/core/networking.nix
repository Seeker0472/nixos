{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  # Enable networking
  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # Open ports in the firewall.
  # TODO！！！！
  networking.firewall = {
    enable = false;
    allowedTCPPorts = [
      80
      443
    ];
    allowedUDPPortRanges = [
      {
        from = 4000;
        to = 4007;
      }
      {
        from = 8000;
        to = 8010;
      }
    ];
  };
  # enable tailscale
  services.tailscale.enable = true;

  # fix dns issue https://github.com/tailscale/tailscale/issues/4254
  # TODO!
  services.resolved.enable =
    !(config.seeker.programs.mihomo.tun.enable && config.seeker.programs.mihomo.enable);
}
