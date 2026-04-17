import ../lib/mk-host-module.nix {
  hostFile = ./home.nix;
  extraModules = [
    (
      {
        inputs,
        lib,
        ...
      }:
      {
        imports = [ inputs.nixos-wsl.nixosModules.wsl ];

        wsl.enable = true;
        wsl.defaultUser = "seeker";
        wsl.startMenuLaunchers = true;

        networking.networkmanager.enable = lib.mkForce false;

        home-manager.users.seeker.imports = [
          ../../users/seeker/server.nix
        ];
      }
    )
  ];
}
