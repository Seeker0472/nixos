{
  config,
  lib,
  ...
}:
let
  fcitx5_enable = config.i18n.inputMethod.enable && config.i18n.inputMethod.type == "fcitx5";
in
{
  config = lib.mkIf fcitx5_enable {
    home-manager.sharedModules = [
      {
        home.file = {
          ".local/share/fcitx5/themes/Nord-Dark".source = ./fcitx5-nord/Nord-Dark;
          ".local/share/fcitx5/themes/Nord-Light".source = ./fcitx5-nord/Nord-Light;
          ".config/fcitx5/conf/classicui.conf".source = ./conf/classicui.conf;
        };
      }
    ];
  };
}
