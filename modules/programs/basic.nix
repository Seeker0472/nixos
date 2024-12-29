{ pkgs, nur, sharedConfig, ... }: {
  imports = [
    ./basic_program.nix
    ./develop_basic.nix
    ./productity_basic.nix
  ] ++ (if sharedConfig.software_package == "cli" then [ ] else [
    # ./vscode.nix
  ]);
}
