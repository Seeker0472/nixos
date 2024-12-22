{ pkgs, ... }:
{
  programs.hyprland = {
    # Install the packages from nixpkgs
    enable = true;
    # Whether to enable XWayland
    # xwayland.enable = true;
  };
  programs.waybar = {
    enable = true;
  };
  # programs.wofi.enable = true;
  environment.systemPackages = with pkgs;[

  ];
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
