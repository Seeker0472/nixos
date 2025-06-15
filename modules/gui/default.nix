{ pkgs, nur, winapps, sharedConfig, ... }:

{
  imports = [ ] ++ (if sharedConfig.desktop_environment == "hyperland" then
      [ ./hyperland.nix ]
    else
      [ ]) ++ (if builtins.elem "tools_full" sharedConfig.software_package then
        #[ ./winapps.nix ]
        []
      else
        [ ]);
}
