{
  lib,
  osConfig,
  ...
}:
let
  kdeconnectEnabled = lib.attrByPath [
    "machine"
    "programs"
    "kdeconnect"
    "enable"
  ] false osConfig;
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
    lib.mkIf kdeconnectEnabled (
      {
        services.kdeconnect.enable = true;
      }
      // (
        if impermanenceEnabled && persistDir != null then
          {
            home.persistence."${persistDir}".directories = [
              ".config/kdeconnect/"
            ];
          }
        else
          { }
      )
    );
}
