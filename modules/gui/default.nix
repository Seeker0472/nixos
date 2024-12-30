{ pkgs, nur, winapps, sharedConfig, ... }: 

{
  imports = [
    # ./anyrun.nix
  ]++(if sharedConfig.desktop_environment == "dwm" then [
    ./dwm.nix
    ./rofi.nix
  ] else [])
  ++(if sharedConfig.desktop_environment == "hyperland" then [
    ./hyperland.nix 
  ] else [])
  ++(if builtins.elem "tools_full" sharedConfig.software_package then 
  [./winapps.nix] else []);
}
