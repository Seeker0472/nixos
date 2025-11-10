# WARN:Last Build Failed, DONOT Commit!
# ##################################################################
#  flake's Entry File,
###################################################################
{
  # inputs 中的每一项依赖有许多类型与定义方式，可以是另一个 flake，也可以是一个普通的 Git 仓库，又或者一个本地路径。
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # seems the nod project supports until 24.05
    nixpkgs-2405.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-2505.url = "github:NixOS/nixpkgs/nixos-25.05"; #don't know how to use it
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs-2405";
    };
    # lock nur
    nur.url = "github:nix-community/NUR";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
      # to have it up-to-date or simply don't specify the nixpkgs input
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager
    home-manager = {
      # url = "github:nix-community/home-manager/release-24.05";
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-2405 = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-2405";
    };
  };
  # function as value
  # an attribute set
  # 它是一个以 inputs 中的依赖项为参数的函数，函数的返回值是一个 attribute set，这个返回的 attribute set 即为该 flake 的构建结果
  outputs = { self, nixpkgs, nixpkgs-2405, nixpkgs-2505, home-manager-2405
    , home-manager, zen-browser, nur, nix-on-droid, sops-nix, ... }@inputs:
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
    in {
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
}
