{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = config.homeProfiles.ai.codex;
  tomlFormat = pkgs.formats.toml { };
  renderedSettings =
    lib.optionalAttrs (cfg.model != null) {
      model = cfg.model;
    }
    // lib.optionalAttrs (cfg.reviewModel != null) {
      review_model = cfg.reviewModel;
    }
    // lib.optionalAttrs cfg.enableHooks {
      features.codex_hooks = true;
    }
    // cfg.settings;
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
    (lib.mkIf (cfg.enable && renderedSettings != { }) {
      home.file.".codex/config.toml".source = tomlFormat.generate "codex-config.toml" renderedSettings;
    })
    (lib.mkIf (cfg.enable && impermanenceEnabled && persistDir != null) {
      home.persistence."${persistDir}".files = [ ".codex/auth.json" ];
    })
  ];
}
