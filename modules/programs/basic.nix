{ pkgs, nur, ... }: {
  imports = [
    ./basic_program.nix
    ./develop_basic.nix
    ./productity_basic.nix
    ./vscode.nix
  ];
}