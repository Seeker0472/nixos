{
  config,
  lib,
  ...
}:
let
  fcitx5_enable = config.i18n.inputMethod.enable && config.i18n.inputMethod.type == "fcitx5";
in
{
  home-manager.sharedModules = lib.optionals fcitx5_enable [
    (
      { lib, osConfig, ... }:
      let
        persistDir = lib.attrByPath [
          "machine"
          "btrfs"
          "impermanence"
          "persistdir"
        ] null osConfig;
      in
      {
        home.file = {
          ".local/share/fcitx5/themes/Nord-Dark".source = ./fcitx5-nord/Nord-Dark;
          ".local/share/fcitx5/themes/Nord-Light".source = ./fcitx5-nord/Nord-Light;
          ".config/fcitx5/conf/classicui.conf".source = ./conf/classicui.conf;
        };
      }
      // (
        if persistDir != null then
          {
            home.persistence."${persistDir}".directories = [
              ".local/share/fcitx5"
              ".config/fcitx5"
            ];
          }
        else
          { }
      )
    )
  ];
}
