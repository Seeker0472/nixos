{ pkgs, nur,  ... }: {
  #imports = [
  #  ./cli.nix
  #] ++ (if (builtins.elem "gui" sharedConfig.software_package) then [
  #  ./gui.nix
  #] else [ ]);
  imports = [./cli.nix ./gui.nix];
}
