{ config, lib, ... }:
{
  options.seeker.virtualization = {
    virtualbox = {
      enable = lib.mkEnableOption "VirtualBox";
    };
    docker = {
      enable = lib.mkEnableOption "Docker";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf config.seeker.virtualization.virtualbox.enable {
      virtualisation.virtualbox.host.enable = true;
      users.extraGroups.vboxusers.members = [ "seeker" ];
    })
    (lib.mkIf config.seeker.virtualization.docker.enable {
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
