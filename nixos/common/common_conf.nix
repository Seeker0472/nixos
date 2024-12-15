{ config, lib, pkgs, modulesPath, ... }:

{
  services.logind.extraConfig = ''
    # don't shutdown when power button is short-pressed
    HandlePowerKey=ignore
  '';
  #Make Windows Happy
  time.hardwareClockInLocalTime = true;

  # time zone.
  time.timeZone = "Asia/Hong_Kong";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_HK.UTF-8";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  #mirror and allfirmware
  hardware.enableAllFirmware = true;
  nix.settings.substituters = [ "https://mirrors.ustc.edu.cn/nix-channels/store" ];

}
