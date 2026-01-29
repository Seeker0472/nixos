{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.seeker.programs.tailscale.enable = lib.mkEnableOption "Tailscale";
  config = lib.mkIf config.seeker.programs.tailscale.enable {
    services.tailscale.enable = true;
    environment.persistence."${config.seeker.btrfs.impermanence.persistdir}" = {
      directories = [
        "/var/lib/tailscale"
      ];
    };
    # fix dns issue https://github.com/tailscale/tailscale/issues/4254
    # TODO!
    services.resolved.enable =
      !(config.seeker.programs.mihomo.tun.enable && config.seeker.programs.mihomo.enable);
  };
}
