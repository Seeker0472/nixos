{
  pkgs,
  lib,
  ...
}:
let
  allFiles = lib.filesystem.listFilesRecursive ./home;

  allHomeProfiles = builtins.filter (
    file:
    let
      name = toString file;
    in
    (lib.hasSuffix ".nix" name) && !(lib.hasPrefix "_" (builtins.baseNameOf name))
  ) allFiles;
in
{
  home-manager.sharedModules = allHomeProfiles;
}
