{ config, ... }:
let
  username = "seeker";
  keyRelativePath = "age/keys";
  keyFilePath =
    if config.seeker.impermanence.enable then
      "${config.seeker.btrfs.impermanence.persistdir}/home/${username}/${keyRelativePath}"
    else
      "/home/${username}/${keyRelativePath}";
in
{
  home-manager.sharedModules = [
    (
      { config, ... }:
      {
        sops.age.keyFile = keyFilePath;
        systemd.user.services.mbsync.unitConfig.After = [ "sops-nix.service" ];
      }
    )
  ];
}
