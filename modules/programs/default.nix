{ pkgs, nur, sharedConfig, ... }: {
  imports = [
    ./cli.nix
  ] ++ (if (builtins.elem "gui" sharedConfig.software_package) then [
    ./gui.nix
  ] else [ ]);
}
