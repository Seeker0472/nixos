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
  home.packages = with pkgs;[
    hyprland-qtutils
    hyprpaper
    hyprlock
    bluetuith
    wofi
    mako
    pavucontrol
    networkmanager
    libnotify
    brightnessctl
    grim
    slurp
  ];
  home.file = 
    mkHomeFile ./hypr ".config/hypr" //
    mkHomeFile ./waybar ".config/waybar" //
    mkHomeFile ./wofi ".config/wofi" //
    mkHomeFile ./wallpaper "Pictures/wallpaper/default" ;

}
