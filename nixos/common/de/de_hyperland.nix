{ pkgs, lib, ... }:
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
    (pkgs.catppuccin-sddm.override {
      flavor = "mocha";
      font = "Maple Mono NF CN";
      # ClockEnabled
      fontSize = "24";
      # background = "${./wallpaper.png}";
      # loginBackground = true;
    }
    )
  ];
  # TODO: the issue may because the compositor of weston
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      autoNumlock = true;
      theme = "catppuccin-mocha";
      package = pkgs.kdePackages.sddm;
/*       settings = {
        Wayland = {
          CompositorCommand = "${lib.getBin pkgs.weston}/bin/weston --shell=kiosk -c /etc/weston/config.ini";
        };
      }; */
    };
    defaultSession = "hyprland";
  };
/*   environment.etc."weston/config.ini".text = ''
    [keyboard]
    keymap_layout=us
    keymap_model=pc104
    keymap_options=terminate:ctrl_alt_bksp
    keymap_variant=

    [libinput]
    enable-tap=true
    left-handed=false

    [output]
    name=eDP-1
    mode=preferred

    [output]
    name=DP-1
    clone-of=eDP-1

    [output]
    name=DP-2
    clone-of=eDP-1

    [output]
    name=DP-3
    clone-of=eDP-1
  ''; */
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
