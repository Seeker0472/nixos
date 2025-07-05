{ pkgs, nur, sharedConfig, ... }: {
  imports = [
    ./cli.nix
  ] ++ (if (builtins.elem "develop" sharedConfig.software_package) then [
    ./gui.nix
  ] else [ ]);
}
