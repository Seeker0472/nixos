{ config, lib, ... }:
{
  options.machine.virtualization = {
    virtualbox = {
      enable = lib.mkEnableOption "VirtualBox";
    };
    docker = {
      enable = lib.mkEnableOption "Docker";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf config.machine.virtualization.virtualbox.enable {
      virtualisation.virtualbox.host.enable = true;
      users.extraGroups.vboxusers.members = [ config.machine.mainUser ];
    })
    (lib.mkIf config.machine.virtualization.docker.enable {
      virtualisation.docker = {
        enable = true;
        # speed-up boot process ,maybe `--restart=always` won't work
        # enableOnBoot = false;
        rootless.setSocketVariable = true;
        #daemon.settings = { data-root = "/etc/docker"; };
      };
    })
  ];
}
