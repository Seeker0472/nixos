{ config, ... }:
{
  home-manager.sharedModules = [
    (
      { osConfig, config, ... }:
      {
        home.persistence."${osConfig.seeker.btrfs.impermanence.persistdir}/home/${config.home.username}" = {
          allowOther = true;
          directories = [
            "Downloads"
            "Documents"
            "Pictures"
            "Videos"
            ".ssh"
            ".gnupg"
          ];
        };
      }
    )
  ];
  # must enable aloneside allowOther
  programs.fuse.userAllowOther = true;

}
