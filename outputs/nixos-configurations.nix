{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib;
  miLaptop = import ../hosts/miLaptop/meta.nix;
  devVM = import ../hosts/devVM/meta.nix;
  gringotts = import ../hosts/GringottsVault713/meta.nix;
  kingsCross = import ../hosts/KingsCross/meta.nix;

  mkNixos =
    {
      system,
      modules,
      baseModules ? [
        ./common
        ../modules
      ],
    }:
    lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = baseModules ++ modules;
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

  devVMConfiguration = mkNixos {
    system = devVM.system;
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
      inputs.home-manager.nixosModules.home-manager
      ../users/home-manager.nix
    ];
    modules = [
      ../hosts/nixos-wsl
      ../users/seeker/wsl.nix
    ];
  };

  kingsCrossConfiguration = mkNixos {
    system = kingsCross.system;
    baseModules = [
      ./common/nixpkgs-settings.nix
      inputs.disko.nixosModules.disko
      inputs.sops-nix.nixosModules.sops
      ../modules/profiles/system/storage/single-disk.nix
    ];
    modules = [ ../hosts/KingsCross ];
  };

  devContainerQemu = devVMConfiguration.config.system.build.vmWithBootLoader;
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

    devVM = devVMConfiguration;
    nixos-wsl = wslConfiguration;
    "King'sCross" = kingsCrossConfiguration;
  };

  perSystem =
    {
      pkgs,
      system,
      ...
    }:
    let
      runDevContainerQemu = pkgs.writeShellScript "run-dev-container-qemu" ''
        state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/dev-container-qemu"
        ${pkgs.coreutils}/bin/mkdir -p "$state_dir"
        export NIX_DISK_IMAGE="''${NIX_DISK_IMAGE:-$state_dir/devVM.qcow2}"
        exec ${devContainerQemu}/bin/run-${devVM.hostName}-vm "$@"
      '';
    in
    {
      packages =
        lib.optionalAttrs (system == gringotts.system) {
          GringottsVault713 = mkProxmoxLXC {
            inherit system;
            modules = [
              ../hosts/GringottsVault713
              ../users/hagrid
            ];
          };
        }
        // lib.optionalAttrs (system == devVM.system) {
          inherit devContainerQemu;
        };
      apps = lib.optionalAttrs (system == devVM.system) {
        devContainerQemu = {
          type = "app";
          program = "${runDevContainerQemu}";
          meta.description = "Build and start the development NixOS VM with QEMU";
        };
      };
    };
}
