{
  config,
  lib,
  pkgs,
  ...
}:
let
  bundles = {
    ai = import ./packages/ai.nix { inherit pkgs; };
    base = import ./packages/base.nix { inherit pkgs; };
    dev = import ./packages/dev.nix { inherit pkgs; };
    media = import ./packages/media.nix { inherit pkgs; };
    office = import ./packages/office.nix { inherit pkgs; };
  };
  enabledBundleNames = lib.filter (
    name:
    lib.attrByPath [
      "homeProfiles"
      "packages"
      name
      "enable"
    ] false config
  ) (builtins.attrNames bundles);
in
{
  home.packages = lib.concatMap (name: bundles.${name}) enabledBundleNames;
}
