{ lib, config, ... }:
{
  options.seeker.programs.steam.enable = lib.mkEnableOption "Steam";
  config = lib.mkMerge [
    (lib.mkIf config.seeker.programs.steam.enable {
      programs.steam = {
        enable = true;
      };
    })
    (lib.mkIf config.seeker.impermanence.enable {
      environment.persistence."${config.seeker.btrfs.impermanence.persistdir}" = {
        # TODO:maybe enable all users
        users.seeker.directories = [
          ".steam"
          ".local/share/Steam"
        ];
      };
    })
  ];
}
