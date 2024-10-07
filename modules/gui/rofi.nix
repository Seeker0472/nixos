#https://github.com/sauricat/flakes/blob/a78f33a08afdbd5b5ba8307fa7f6c1c2ef37ab88/home/mapping.nix

{ config, lib, pkgs, ... }:
let
  copyDir = fromDir: toDir: # fromDir is a path, toDir is a string.
    lib.mapAttrs'
      (name: value: lib.nameValuePair (toDir + "/" + name)
                                      (fromDir + "/${name}"))
      (lib.filterAttrs (name: value: value == "regular")
                       (builtins.readDir fromDir));
  copyDirRecursively = fromDir: toDir:
    builtins.foldl'
      (a: b: a // b)
      (copyDir fromDir toDir)
      (lib.mapAttrsToList (name: value: copyDirRecursively (fromDir + "/${name}")
                                                           (toDir + "/" + name))
                          (lib.filterAttrs (name: value: value == "directory")
                                           (builtins.readDir fromDir)));
  mkHomeFile = fromDir: toDir:
    lib.mapAttrs'
      (name: value: lib.nameValuePair name ({ source = lib.mkDefault value; }))
      (copyDirRecursively fromDir toDir);
in
{
  home.file =
    mkHomeFile ./rofi ".local/share/rofi";
}