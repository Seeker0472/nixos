{ lib, config, ... }:
{
  options.machine.programs.steam.enable = lib.mkEnableOption "Steam";
  config = lib.mkMerge [
    (lib.mkIf config.machine.programs.steam.enable {
      programs.steam = {
        enable = true;
      };
    })
    (lib.mkIf (config.machine.programs.steam.enable && config.machine.impermanence.enable) {
      environment.persistence."${config.machine.btrfs.impermanence.persistdir}" = {
        # TODO:maybe enable all users
        users.${config.machine.mainUser}.directories = [
          ".steam"
          ".local/share/Steam"
        ];
      };
    })
  ];
}
