{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib;
  miLaptop = import ../hosts/miLaptop/meta.nix;
  diagonalAlley = import ../hosts/DiagonAlley/meta.nix;
  devVM = import ../hosts/devVM/meta.nix;
  kingsCross = import ../hosts/KingsCross/meta.nix;
  burrow = import ../hosts/burrow/meta.nix;

  mkNixos =
    {
      system,
      modules,
      baseModules,
    }:
    lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = baseModules ++ modules;
    };

  miLaptopConfiguration = mkNixos {
    inherit (miLaptop) system;
    baseModules = [
      ./common/nixpkgs-settings.nix
      ../modules/bundles/desktop.nix
    ];
    modules = [
      ../hosts/miLaptop
      ../users/seeker
    ];
  };

  devVMConfiguration = mkNixos {
    inherit (devVM) system;
    baseModules = [
      ./common/nixpkgs-settings.nix
      ../modules/bundles/development.nix
    ];
    modules = [
      ../hosts/devVM
      ../users/seeker/headless.nix
    ];
  };

  wslConfiguration = mkNixos {
    system = "x86_64-linux";
    baseModules = [
      ./common/nixpkgs-settings.nix
      inputs.nixos-wsl.nixosModules.default
      ../modules/bundles/wsl.nix
    ];
    modules = [
      ../hosts/nixos-wsl
      ../users/seeker/wsl.nix
    ];
  };

  kingsCrossConfiguration = mkNixos {
    inherit (kingsCross) system;
    baseModules = [
      ./common/nixpkgs-settings.nix
      ../modules/bundles/server.nix
    ];
    modules = [ ../hosts/KingsCross ];
  };

  devVMQemu = devVMConfiguration.config.system.build.vmWithBootLoader;
in
{
  flake.nixosConfigurations = {
    miLaptop = miLaptopConfiguration;
    DiagonAlley = mkNixos {
      inherit (diagonalAlley) system;
      baseModules = [
        ./common/nixpkgs-settings.nix
        ../modules/bundles/desktop.nix
      ];
      modules = [
        ../hosts/DiagonAlley
        ../users/seeker
      ];
    };
    devVM = devVMConfiguration;
    nixos-wsl = wslConfiguration;
    "King'sCross" = kingsCrossConfiguration;
    burrow = mkNixos {
      inherit (burrow) system;
      baseModules = [
        ./common/nixpkgs-settings.nix
        ../modules/bundles/gateway.nix
      ];
      modules = [
        ../hosts/burrow
        ../users/seeker/burrow.nix
      ];
    };
  };

  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    let
      runDevVmQemu = pkgs.writeShellScript "run-dev-vm-qemu" ''
        state_root="''${XDG_STATE_HOME:-$HOME/.local/state}"
        state_dir="$state_root/dev-vm-qemu"
        legacy_state_dir="$state_root/dev-container-qemu"
        if [ ! -e "$state_dir/devVM.qcow2" ] && [ -e "$legacy_state_dir/devVM.qcow2" ]; then
          state_dir="$legacy_state_dir"
        fi
        ${pkgs.coreutils}/bin/mkdir -p "$state_dir"
        export NIX_DISK_IMAGE="''${NIX_DISK_IMAGE:-$state_dir/devVM.qcow2}"
        exec ${devVMQemu}/bin/run-${devVM.hostName}-vm "$@"
      '';
    in
    {
      packages = lib.optionalAttrs (system == devVM.system) {
        inherit devVMQemu;
      };
      apps = lib.optionalAttrs (system == devVM.system) {
        devVMQemu = {
          type = "app";
          program = "${runDevVmQemu}";
          meta.description = "Build and start the development NixOS VM with QEMU";
        };
      };
    };
}
