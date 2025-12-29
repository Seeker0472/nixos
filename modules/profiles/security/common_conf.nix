{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-qt;
  };
}
