let
  system = "x86_64-linux";
  config_miLaptop = import ./config/sharedConfig_miLaptop.nix;
  config_LTG = import ./config/sharedConfig_LTG.nix;
  config_miPad = import ./config/sharedConfig_miPad.nix;

  pkgsConfig = {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays = [ nur.overlays.default ];
  };
  home_managerConfig = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.seeker = import users/seeker/home.nix;
      backupFileExtension = "backup";
      sharedModules = [
        inputs.sops-nix.homeManagerModules.sops
        inputs.zen-browser.homeModules.beta
      ];
    };
  };
in
{
  inherit system;
  # configuration for Laptop
  nixosConfigurations.miLaptop = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit (config_miLaptop) sharedConfig;
    };

    # TODO: nixpkgs/flake.nix 中找到 nixpkgs.lib.nixosSystem 的定义，跟踪它的源码，研究其实现方式。
    modules = [
      ./nixos
      pkgsConfig
      # home-manager as nixos module
      home-manager.nixosModules.home-manager
      {
        # What that supposed to mean?
        home-manager.extraSpecialArgs = {
          inherit (config_miLaptop) sharedConfig;
        };
      }
      sops-nix.nixosModules.sops
      home_managerConfig
    ];
  };
  nixosConfigurations.LTG = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit (config_LTG) sharedConfig; };
    modules = [
      ./nixos
      pkgsConfig
      home-manager.nixosModules.home-manager
      {
        home-manager.extraSpecialArgs = {
          inherit (config_LTG) sharedConfig;
        };
      }
      home_managerConfig
    ];
  };
  nixOnDroidConfigurations.default =
    nix-on-droid.lib.nixOnDroidConfiguration {
      pkgs = import nixpkgs-2405 { system = "aarch64-linux"; };
      # specialArgs = { inherit (config_miPad) sharedConfig; };
      modules = [
        ./nixos/miPad
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            config = ./users/nix-on-droid;
            extraSpecialArgs = { inherit (config_miPad) sharedConfig; };
          };
        }
      ];

    };
};
