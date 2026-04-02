{
  lib,
  osConfig,
  ...
}:
let
  fcitx5Enable =
    (lib.attrByPath [
      "i18n"
      "inputMethod"
      "enable"
    ] false osConfig)
    && (lib.attrByPath [
      "i18n"
      "inputMethod"
      "type"
    ] "" osConfig)
    == "fcitx5";
  impermanenceEnabled = lib.attrByPath [
    "machine"
    "impermanence"
    "enable"
  ] false osConfig;
  persistDir = lib.attrByPath [
    "machine"
    "btrfs"
    "impermanence"
    "persistdir"
  ] null osConfig;
in
{
  config =
    lib.mkIf fcitx5Enable (
      {
        home.file = {
          ".local/share/fcitx5/themes/Nord-Dark".source = ./fcitx5-nord/Nord-Dark;
          ".local/share/fcitx5/themes/Nord-Light".source = ./fcitx5-nord/Nord-Light;
          ".config/fcitx5/conf/classicui.conf".source = ./conf/classicui.conf;
        };
      }
      // (
        if impermanenceEnabled && persistDir != null then
          {
            home.persistence."${persistDir}".directories = [
              ".local/share/fcitx5"
              ".config/fcitx5"
            ];
          }
        else
          { }
      )
    );
}
