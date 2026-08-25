let
  files = {
    admin = ./ssh/admin.secrets.json;
    external = ./ssh/external.secrets.json;
    miLaptop = ./ssh/miLaptop.secrets.json;
    devVM = ./ssh/devVM.secrets.json;
    nixos-wsl = ./ssh/nixos-wsl.secrets.json;
    github = ./ssh/github.secrets.json;
  };
  readPublicKey = file: (builtins.fromJSON (builtins.readFile file)).public_key_unencrypted;
in
{
  inherit files;

  admin = readPublicKey files.admin;
  external = readPublicKey files.external;

  clients = {
    miLaptop = readPublicKey files.miLaptop;
    devVM = readPublicKey files.devVM;
    nixos-wsl = readPublicKey files.nixos-wsl;
  };

  github = readPublicKey files.github;

  authorizedKeys = [
    (readPublicKey files.admin)
    (readPublicKey files.miLaptop)
    (readPublicKey files.devVM)
    (readPublicKey files.nixos-wsl)
  ];
}
