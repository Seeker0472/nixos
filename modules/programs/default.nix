{ pkgs, nur, ... }: {
  imports = [
    ./basic.nix
    ./broswer.nix
    ./develop.nix
    ./multimedia.nix
    ./productity.nix
  ];
}

