{ pkgs, nur, ... }: {
  imports = [
    ./anyrun.nix
    ./dwm.nix
    ./rofi.nix
  ];
}
