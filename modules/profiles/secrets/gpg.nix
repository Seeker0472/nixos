{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  # TODO: manage by nix and persist it
  programs.gnupg.agent = {
    enable = lib.mkDefault true;
    pinentryPackage = pkgs.pinentry-qt;
  };
}
