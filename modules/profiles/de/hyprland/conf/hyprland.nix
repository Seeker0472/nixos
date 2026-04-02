{ pkgs, ... }:
{
  home-manager.sharedModules = [
    (
      { lib, osConfig, ... }:
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
        home.packages = [ pkgs.nwg-displays ]; # set display for hyprland
        wayland.windowManager.hyprland = {
          enable = true;
          systemd.enable = true;
          extraConfig = ''
            # source the nwg-displays generated config
            source = ./monitors.conf
          '';
          settings = {
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
        };
      }
      // (
        if impermanenceEnabled && persistDir != null then
          {
            home.persistence."${persistDir}".directories = [
              ".config/hypr"
              ".local/share/hyprland"
            ];
          }
        else
          { }
      )
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
