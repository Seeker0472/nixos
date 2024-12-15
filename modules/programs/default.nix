{ pkgs, nur, sharedConfig, ... }: {
  imports = [
    ./basic.nix
  ] ++ (if sharedConfig.software_package == "full" then
    [
      ./broswer.nix
      ./develop.nix
      ./multimedia.nix
      ./productity.nix
    ]
  else [ ]);
}

