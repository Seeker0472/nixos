{ pkgs, nur, winapps, sharedConfig, ... }: 

{
  imports = [
    ./anyrun.nix
    ./winapps.nix
  ]++(if sharedConfig.desktop_environment == "dwm" then [
    ./dwm.nix
    ./rofi.nix
  ] else []);
}
