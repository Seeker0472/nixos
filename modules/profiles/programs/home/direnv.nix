{
  config,
  osConfig,
  lib,
  ...
}:
let
  cfg = config.homeProfiles.cli.direnv;
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
lib.mkMerge [
  (lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      # enableBashIntegration =true;
      # enableFishIntegration = true;
      nix-direnv.enable = true;
      config = {
        hide_env_diff = true;
      };
    };
  })
  (lib.mkIf (cfg.enable && impermanenceEnabled && persistDir != null) {
    home.persistence."${persistDir}".directories = [
      ".local/share/direnv"
    ];
  })
]
