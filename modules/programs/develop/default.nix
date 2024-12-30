{ pkgs, nur, sharedConfig, ... }: {
  imports = [
  ] ++ (if ((builtins.elem "develop" sharedConfig.software_package) || (builtins.elem "develop_full" sharedConfig.software_package)) then [
    ./develop.nix
    # ./vscode.nix
  ] else [ ]);
  }
