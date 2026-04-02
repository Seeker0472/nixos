{
  config,
  osConfig,
  lib,
  ...
}:
let
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
  programs.direnv = {
    # enable = true;
    # enableBashIntegration =true;
    # enableFishIntegration = true;
    nix-direnv.enable = true;
    config = {
      hide_env_diff = true;
    };
  };
}
// (
  if impermanenceEnabled && persistDir != null then
    {
      home.persistence."${persistDir}".directories = [
        ".local/share/direnv"
      ];
    }
  else
    { }
)
