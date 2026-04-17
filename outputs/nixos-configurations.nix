{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib;
  devContainerModules = [
    ../hosts/devContainer
    ../users/seeker/headless.nix
  ];
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
  mkContainerArchive =
    {
      pkgs,
      imageName,
      imageTag ? "latest",
      systemConfig,
    }:
    let
      mainUser = systemConfig.config.machine.mainUser;
      homeDirectory = systemConfig.config.users.users.${mainUser}.home;
      userProfileBin = "/etc/profiles/per-user/${mainUser}/bin";
    in
    pkgs.dockerTools.buildLayeredImage {
      name = imageName;
      tag = imageTag;
      compressor = "none";
      contents = [ systemConfig.config.system.build.toplevel ];
      config = {
        Cmd = [ "/sw/bin/fish" ];
        Env = [
          "container=oci"
          "HOME=${homeDirectory}"
          "PATH=${userProfileBin}:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
          "SHELL=/sw/bin/fish"
          "USER=${mainUser}"
        ];
        StopSignal = "SIGRTMIN+3";
        User = mainUser;
        WorkingDir = homeDirectory;
        Volumes = {
          "/run" = { };
          "/tmp" = { };
        };
      };
    };
  mkOCIArchive =
    {
      pkgs,
      imageName,
      imageTag ? "latest",
      systemConfig,
    }:
    let
      dockerArchive = mkContainerArchive {
        inherit
          pkgs
          imageName
          imageTag
          systemConfig
          ;
      };
    in
    pkgs.runCommand "${imageName}-oci-archive.tar"
      {
        nativeBuildInputs = [ pkgs.skopeo ];
      }
      ''
        export TMPDIR="$PWD/tmp"
        mkdir -p "$TMPDIR"
        skopeo --insecure-policy --tmpdir "$TMPDIR" copy \
          docker-archive:${dockerArchive} \
          oci-archive:$out:${imageName}:${imageTag}
      '';
in
{
  flake.nixosConfigurations = {
    miLaptop = mkNixos {
      system = "x86_64-linux";
      modules = [
        ../hosts/miLaptop
        ../users/seeker
      ];
    };
    devContainer = mkNixos {
      system = "x86_64-linux";
      modules = devContainerModules;
    };
    wsl = mkNixos {
      system = "x86_64-linux";
      modules = [
        ../hosts/wsl
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
      packages = lib.optionalAttrs (system == "x86_64-linux") (
        let
          devContainerConfig = mkNixos {
            inherit system;
            modules = devContainerModules;
          };
        in
        {
          GringottsVault713 = mkProxmoxLXC {
            inherit system;
            modules = [ ../hosts/GringottsVault713 ];
          };
          devContainer = mkProxmoxLXC {
            inherit system;
            modules = devContainerModules;
          };
          devContainerDocker = mkContainerArchive {
            inherit pkgs;
            imageName = "nixos-devcontainer";
            systemConfig = devContainerConfig;
          };
          devContainerOCI = mkOCIArchive {
            inherit pkgs;
            imageName = "nixos-devcontainer";
            systemConfig = devContainerConfig;
          };
        }
      );
    };
}
