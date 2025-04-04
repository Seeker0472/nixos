{ pkgs, nur, sharedConfig, ... }: {
  imports = [ ] ++ (if ((builtins.elem "tools" sharedConfig.software_package)
    || (builtins.elem "tools_full" sharedConfig.software_package)) then [
      ./basic.nix
      ./broswer.nix
      ./productivity.nix
    ] else
    [ ]);
}
