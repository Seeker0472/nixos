{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib;
  miLaptop = import ../hosts/miLaptop/meta.nix;
  devVM = import ../hosts/devVM/meta.nix;
  gringotts = import ../hosts/GringottsVault713/meta.nix;

  mkNixos =
    {
      system,
      modules,
    }:
    lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./common
        ../modules
      ]
      ++ modules;
    };

  mkProxmoxLXC =
    {
      system,
      modules,
    }:
    (mkNixos {
      inherit system;
      modules = modules ++ [ "${inputs.nixpkgs}/nixos/modules/virtualisation/proxmox-lxc.nix" ];
    }).config.system.build.image;
in
{
  flake.nixosConfigurations = {
    miLaptop = mkNixos {
      system = miLaptop.system;
      modules = [
        ../hosts/miLaptop
        ../users/seeker
      ];
    };

    devVM = mkNixos {
      system = devVM.system;
      modules = [
        ../hosts/devVM
        ../users/seeker/headless.nix
      ];
    };
  };

  perSystem =
    { system, ... }:
    {
      packages = lib.optionalAttrs (system == gringotts.system) {
        GringottsVault713 = mkProxmoxLXC {
          inherit system;
          modules = [
            ../hosts/GringottsVault713
            ../users/hagrid
          ];
        };
      };
    };
}
