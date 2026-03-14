{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib;
  nixpkgsConfig = import ./common/nixpkgs-config.nix { inherit inputs; };
  mkPkgs =
    system:
    import inputs.nixpkgs (
      {
        inherit system;
      }
      // nixpkgsConfig
    );

  allHomeProfiles =
    let
      allFiles = lib.filesystem.listFilesRecursive ../modules/profiles/programs/home;
    in
    builtins.filter (
      file:
      let
        name = toString file;
      in
      lib.hasSuffix ".nix" name && !(lib.hasPrefix "_" (builtins.baseNameOf name))
    ) allFiles;

  extractSharedModules =
    {
      pkgs,
      syntheticConfig,
    }:
    module:
    let
      evaluated = import module {
        inherit lib pkgs;
        config = syntheticConfig;
      };
    in
    lib.attrByPath
      [
        "home-manager"
        "sharedModules"
      ]
      [ ]
      evaluated
    ++
      lib.attrByPath
        [
          "config"
          "home-manager"
          "sharedModules"
        ]
        [ ]
        evaluated;

  mkStandaloneHome =
    {
      host,
      userModule,
      baseModules ? [ ],
      sharedModuleSources ? [ ],
    }:
    let
      pkgs = mkPkgs host.system;
      sharedModules =
        baseModules
        ++ lib.concatMap (extractSharedModules {
          inherit pkgs;
          syntheticConfig = host.standalone.syntheticConfig;
        }) sharedModuleSources;
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        osConfig = host.standalone.osConfig;
      };
      modules = sharedModules ++ [ userModule ];
    };

  miLaptopHost = import ../hosts/miLaptop/home.nix;
  serverHost = import ../hosts/GringottsVault713/home.nix;
in
{
  flake.homeConfigurations = {
    "seeker@miLaptop" = mkStandaloneHome {
      host = miLaptopHost;
      userModule = ../users/seeker/home.nix;
      baseModules = [
        inputs.sops-nix.homeManagerModules.sops
        inputs.zen-browser.homeModules.beta
        inputs.nixvim.homeModules.nixvim
      ]
      ++ allHomeProfiles;
      sharedModuleSources = [
        ../modules/profiles/sops/default.nix
        ../modules/profiles/de/options.nix
        ../modules/profiles/de/map.nix
        ../modules/profiles/de/hyprland/default.nix
        ../modules/profiles/de/waybar/default.nix
        ../modules/profiles/input/map.nix
        ../modules/profiles/programs/kde-connect.nix
      ];
    };

    "hagrid@GringottsVault713" = mkStandaloneHome {
      host = serverHost;
      userModule = ../users/hagrid/home.nix;
    };
  };
}
