{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  nix.settings = {
    substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
    ];
    auto-optimise-store = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  # Select internationalisation properties.
  i18n.defaultLocale = "en_HK.UTF-8";

  nixpkgs.config.permittedInsecurePackages = [ ];
  #Make Windows Happy
  # A better way is to let windows use UTC time
  # time.hardwareClockInLocalTime = true;

  # time zone.
  time.timeZone = "Asia/Hong_Kong";

  environment.variables.EDITOR = lib.mkOverride 950 "vim";

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    python3
    fish
    rclone
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
