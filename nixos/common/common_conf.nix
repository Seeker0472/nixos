{ config, lib, pkgs, modulesPath, ... }:

{
  services.logind.extraConfig = ''
    # don't shutdown when power button is short-pressed
    HandlePowerKey=ignore
  '';
  #Make Windows Happy
  # A better way is to let windows use UTC time
  # time.hardwareClockInLocalTime = true;

  # time zone.
  time.timeZone = "Asia/Hong_Kong";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_HK.UTF-8";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  #mirror and allfirmware
  hardware.enableAllFirmware = true;
  nix.settings.substituters = [
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://mirrors.ustc.edu.cn/nix-channels/store"
  ];

  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Optimise storage
  # you can also optimise the store manually via:
  #    nix-store --optimise
  # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
  nix.settings.auto-optimise-store = true;

  # keyd to remap keys, caps->esc
  # wiki on https://wiki.nixos.org/wiki/Keyd
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            capslock = "esc";
            esc = "esc";
          };
          otherlayer = { };
        };
        extraConfig = ''
        '';
      };
    };
  };

}
