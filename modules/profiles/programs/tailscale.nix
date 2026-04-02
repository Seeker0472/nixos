{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.machine.programs.tailscale.enable = lib.mkEnableOption "Tailscale";
  config = lib.mkMerge [
    (lib.mkIf config.machine.programs.tailscale.enable {
      services.tailscale.enable = true;
      # fix dns issue https://github.com/tailscale/tailscale/issues/4254
      # TODO!
      services.resolved.enable =
        !(config.machine.programs.mihomo.tun.enable && config.machine.programs.mihomo.enable);
    })
    (lib.mkIf (config.machine.programs.tailscale.enable && config.machine.impermanence.enable) {
      environment.persistence."${config.machine.btrfs.impermanence.persistdir}" = {
        directories = [
          "/var/lib/tailscale"
        ];
      };
    })
  ];
}
