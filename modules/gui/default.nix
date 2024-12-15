{ pkgs, nur, winapps, sharedConfig, ... }: 

{
  imports = [
    ./anyrun.nix
  ]++(if sharedConfig.desktop_environment == "dwm" then [
    ./dwm.nix
    ./rofi.nix
  ] else [])
  ++(if sharedConfig.software_package == "full" then 
  [./winapps.nix] else []);
}
