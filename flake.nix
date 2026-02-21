# ##################################################################
#  flake's Entry File,
###################################################################
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # seems the nod project supports until 24.05
    nixpkgs-2405.url = "github:NixOS/nixpkgs/nixos-24.05";
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs-2405";
    };
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
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-2405 = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-2405";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    impermanence.url = "github:nix-community/impermanence";
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      # If using a stable channel you can use `url = "github:nix-community/nixvim/nixos-<version>"`
    };
  };
  # function as value
  # an attribute set
  # 它是一个以 inputs 中的依赖项为参数的函数，函数的返回值是一个 attribute set，这个返回的 attribute set 即为该 flake 的构建结果
  outputs =
    {
      self,
      flake-parts,
      nixpkgs,
      ...
    }@inputs:
    # https://flake.parts/module-arguments.html
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # Optional: use external flake logic, e.g.
        # inputs.foo.flakeModules.default
        ./outputs
        inputs.git-hooks-nix.flakeModule
      ];
      flake = {
        # Put your original flake attributes here.
      };
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      perSystem =
        {
          config,
          pkgs,
          ...
        }:
        {
          # Recommended: move all package definitions here.
          # e.g. (assuming you have a nixpkgs input)
          # packages.foo = pkgs.callPackage ./foo/package.nix { };
          # packages.bar = pkgs.callPackage ./bar/package.nix {
          #   foo = config.packages.foo;
          # };
        };
    };
}
