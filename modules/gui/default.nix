{ pkgs, nur, winapps, sharedConfig, ... }:

{
  imports = [ ] ++ (if sharedConfig.desktop_environment == "hyperland" then
    [ ./hyperland.nix ]
  else
    [ ]);
}
