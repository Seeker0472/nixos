let
  base = import ../common/seeker-base.nix;
in
{
  system = base.system;
  hostName = "wsl";
  stateVersion = base.stateVersion;

  machine = base.machine // {
    type = "container";
    cpu = "others";
    impermanence.enable = false;

    users = (base.machine.users or { }) // {
      hagrid.enable = false;
    };

    de = {
      hyprland.enable = false;
      waybar.enable = false;
      wofi.enable = false;
      mako.enable = false;
      wpaperd.enable = false;
    };

    programs = {
      kdeconnect.enable = false;
      mihomo = {
        enable = false;
        tun.enable = false;
      };
      thunar.enable = false;
      steam.enable = false;
      tailscale.enable = false;
      winapps.enable = false;
    };

    secrets = (base.machine.secrets or { }) // {
      ageKeyPath = "/home/seeker/.config/sops/age/keys.txt";
    };

    services = (base.machine.services or { }) // {
      openssh = (base.machine.services.openssh or { }) // {
        enable = true;
        passwordAuthentication = false;
        openFirewall = false;
      };
    };

    features = {
      launcher.aloha.enable = false;
      lidSwitch.enable = false;
    };

    virtualization = {
      docker.enable = false;
      virtualbox.enable = false;
    };
  };
}
