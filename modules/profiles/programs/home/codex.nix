{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = config.homeProfiles.ai.codex;
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
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home.packages = [ pkgs.codex ];
    })
    (lib.mkIf (cfg.enable && impermanenceEnabled && persistDir != null) {
      home.persistence."${persistDir}".directories = [
        ".codex"
      ];
    })
  ];
}
