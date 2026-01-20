{ pkgs, ... }:
{
  home-manager.sharedModules = [
    (
      { config, osConfig, ... }:
      {
        home.packages = [ pkgs.nwg-displays ]; # set display for hyprland
        wayland.windowManager.hyprland.extraConfig = ''
          # source the nwg-displays generated config
          source = ./monitors.conf
        '';
        wayland.windowManager.hyprland.settings = {
          "$menu" = "wofi --show drun -a";

          env = [
            "QT_QPA_PLATFORM,wayland;xcb"
            "QT_IM_MODULE,fcitx"
            # "HYPRCURSOR_THEME,default"
            # "HYPRCURSOR_SIZE,24"
          ];

          # monitor = [
          #   "eDP-1,2560x1600@120,0x0,1.3333333"
          #   "desc:Shenzhen KTC Technology Group H27V22 0x00000001,preferred,auto,auto"
          #   "desc:Dell Inc. DELL U2723QE JSGRL04,preferred,-2560x0,1.5"
          #   ",preferred,auto,auto"
          # ];

          xwayland = {
            force_zero_scaling = true;
          };
        };
        home.persistence."${osConfig.seeker.btrfs.impermanence.persistdir}".directories = [
          ".config/hypr"
          ".local/share/hyprland"
        ];
      }
    )
  ];
  programs.hyprland = {
    # Install the packages from nixpkgs
    enable = true;
    # Whether to enable XWayland
    # xwayland.enable = true;
  };
  services.displayManager = {
    gdm = {
      enable = true;
      settings = { };
    };
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
