{ pkgs, lib, ... }: {
  programs.hyprland = {
    # Install the packages from nixpkgs
    enable = true;
    # Whether to enable XWayland
    # xwayland.enable = true;
  };
  programs.waybar = { enable = true; };
  # programs.wofi.enable = true;
  environment.systemPackages = with pkgs;
    [
      (pkgs.catppuccin-sddm.override {
        flavor = "mocha";
        font = "Maple Mono NF CN";
        # ClockEnabled
        fontSize = "24";
        # background = "${./wallpaper.png}";
        # loginBackground = true;
      })
    ];
  # TODO: the issue may because the compositor of weston
  services.displayManager = {
    # sddm = {
    #   enable = true;
    #   wayland.enable = true;
    #   autoNumlock = true;
    #   theme = "catppuccin-mocha";
    #   package = pkgs.kdePackages.sddm;
    # };
    gdm = {
      enable = true;
      settings = {
        };
      };
    };
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
