{ config, lib, pkgs, modulesPath, ... }:

{
  networking.hostName = "LTG"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  # Configure network proxy if necessary
  #   networking.proxy.default = "http://localhost:7890";
  # networking.proxy.default = "http://192.168.1.6:7890";
  #   networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  # Open ports in the firewall.
  # TODO！！！！
  networking.firewall = {
    enable = false;
    allowedTCPPorts = [ 80 443 ];
    allowedUDPPortRanges = [
      { from = 4000; to = 4007; }
      { from = 8000; to = 8010; }
    ];
  };
  # enable tailscale
  services.tailscale.enable = true;
  # fix dns issue https://github.com/tailscale/tailscale/issues/4254
  services.resolved.enable = true;
  # services.tailscale.useRoutingFeatures="both";
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
