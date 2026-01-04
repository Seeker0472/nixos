{ inputs, ... }:
{
  flake.nixosConfigurations = {
    miLaptop = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; }; # 只传 inputs 即可
      modules = [
        ../hosts/miLaptop
        ./common
        ../modules
        ../users/seeker
      ];
    };
  };
  perSystem =
    {
      config,
      pkgs,
      system,
      ...
    }:
    {
      packages = {
        GringottsVault713 = inputs.nixos-generators.nixosGenerate {
          system = system;
          format = "proxmox-lxc";
          specialArgs = { inherit inputs; };
          modules = [
            ./common
            ../hosts/GringottsVault713
            ../modules
          ];
        };
      };
    };
}
