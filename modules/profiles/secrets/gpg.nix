{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.machine.programs.gpg.enable = lib.mkEnableOption "GnuPG agent";

  config = lib.mkIf config.machine.programs.gpg.enable {
    programs.gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-qt;
    };
  };
}
