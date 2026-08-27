{ inputs, ... }:
{
  imports = [
    ./development.nix
    inputs.impermanence.nixosModule
    inputs.disko.nixosModules.disko
    ../profiles/impermanence/btrfs.nix
    ../profiles/impermanence/config.nix
    ../profiles/de/hyprland/default.nix
    ../profiles/de/niri/default.nix
    ../profiles/de/options.nix
    ../profiles/programs/gnome-keyring.nix
    ../profiles/programs/kde-connect.nix
    ../profiles/programs/mihomo/mihomo.nix
    ../profiles/programs/netbird.nix
    ../profiles/programs/steam.nix
    ../profiles/programs/tailscale.nix
    ../profiles/programs/thunar.nix
    ../profiles/programs/winapps.nix
    ../profiles/secrets/gpg.nix
    ../profiles/system/core/virtualization.nix
    ../profiles/system/hardware/intel.nix
    ../profiles/system/hardware/laptop.nix
  ];
}
