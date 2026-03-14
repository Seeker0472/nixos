{
  config,
  osConfig,
  lib,
  ...
}:
let
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
  if persistDir != null then
    {
      home.persistence."${persistDir}".directories = [
        ".local/share/direnv"
      ];
    }
  else
    { }
)
