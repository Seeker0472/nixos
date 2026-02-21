{ lib, config, ... }:
let
  allConfigFiles = lib.filesystem.listFilesRecursive ./config;
  nvimConfig = builtins.filter (
    file:
    let
      name = toString file;
    in
    (lib.hasSuffix ".nix" name)
  ) allConfigFiles;
in
{
  programs.nixvim = {
    enable = true;
    imports = nvimConfig;
  };
}
