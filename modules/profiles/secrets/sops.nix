{
  config,
  pkgs,
  ...
}:
let
  username = "seeker";
  keyRelativePath = "age/keys";
in
{
  sops.age.keyFile =
    if config.seeker.impermanence.enable then
      "${config.seeker.btrfs.impermanence.persistdir}/home/${username}/${keyRelativePath}"
    else
      "/home/${username}/${keyRelativePath}";

}
