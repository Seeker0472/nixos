{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib;
  nixpkgsConfig = import ./common/nixpkgs-config.nix { inherit inputs; };
  mkStandaloneHome =
    { host, userModule }:
    let
      pkgs = import inputs.nixpkgs (
        {
          inherit (host) system;
        }
        // nixpkgsConfig
      );

      hostContext = lib.nixosSystem {
        inherit (host) system;
        specialArgs = { inherit inputs; };
        modules = [
          ./common
          ../modules
          (
            {
              lib,
              ...
            }:
            {
              networking.hostName = host.hostName;
              system.stateVersion = host.stateVersion;
              machine = host.machine;
              home-manager.users = { };
            }
            // lib.attrByPath [
              "standalone"
              "extraConfig"
            ] { } host
          )
        ];
      };
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        osConfig = hostContext.config;
        hostMeta = host;
      };
      modules = hostContext.config.home-manager.sharedModules ++ [ userModule ];
    };
  homeTargets = {
    "seeker@miLaptop" = {
      host = import ../hosts/miLaptop/home.nix;
      userModule = ../users/seeker/home.nix;
    };
    "seeker@devContainer" = {
      host = import ../hosts/devContainer/home.nix;
      userModule = {
        imports = [
          ../users/seeker/home.nix
          ../users/seeker/server.nix
        ];
      };
    };
    "seeker4721@gpu02" = {
      host = import ../hosts/gpu02/home.nix;
      userModule = {
        imports = [
          ../users/seeker/home.nix
          ../users/seeker/server.nix
          ../users/seeker/gpu02.nix
        ];
      };
    };
    "hagrid@GringottsVault713" = {
      host = import ../hosts/GringottsVault713/home.nix;
      userModule = ../users/hagrid/home.nix;
    };
  };
in
{
  flake.homeConfigurations = lib.mapAttrs (_: spec: mkStandaloneHome spec) homeTargets;
}
