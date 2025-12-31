{ config, ... }:
{
  # virtualisation
  virtualisation.virtualbox.host.enable = true;
  virtualisation.docker = {
    enable = true;
    # speed-up boot process ,maybe `--restart=always` won't work
    # enableOnBoot = false;
    rootless.setSocketVariable = true;
    #daemon.settings = { data-root = "/etc/docker"; };
  };
  users.extraGroups.vboxusers.members = [ "seeker" ];
}
