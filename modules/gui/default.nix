{ pkgs, nur, winapps, ... }: {
  imports = [
    ./anyrun.nix
    ./dwm.nix
    ./rofi.nix
    ./winapps.nix
  ];
}
