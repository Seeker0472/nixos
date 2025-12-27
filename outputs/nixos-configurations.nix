{ inputs, ... }: {
  flake.nixosConfigurations = {
    miLaptop = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; }; # 只传 inputs 即可
      modules = [
        ../nixos # 基础系统配置
        ./modules/nixpkgs-settings.nix
        ./modules/user-seeker.nix
        inputs.sops-nix.nixosModules.sops
      ];
    };

    LTG = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [ ../nixos ./nixpkgs-settings.nix ./user-seeker.nix ];
    };
  };
}
