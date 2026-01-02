{ inputs, ... }:
{
  flake.nixosConfigurations = {
    miLaptop = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; }; # 只传 inputs 即可
      modules = [
        ../hosts/miLaptop
        ./common/nixpkgs-settings.nix
        ../modules
        ../users/seeker
        inputs.sops-nix.nixosModules.sops
        inputs.disko.nixosModules.disko
        inputs.impermanence.nixosModule
      ];
    };

    LTG = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ../nixos
        ./nixpkgs-settings.nix
        ../users/seeker
      ];
    };
  };
}
