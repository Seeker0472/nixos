###################################################################
#  flake's Entry File,
###################################################################
{
  # inputs 中的每一项依赖有许多类型与定义方式，可以是另一个 flake，也可以是一个普通的 Git 仓库，又或者一个本地路径。
  inputs = {
    # 定义了 nixpkgs 这一个依赖项，使用的是 flake 中最常见的引用方式，即github:owner/name/reference，这里的 reference 可以是分支名、commit-id 或 tag。

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    # lock nur
    nur.url = "github:nix-community/NUR/7093ba2ffda3283744417f72e1ad6462f748da4d";
    anyrun.url = "github:anyrun-org/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs";
    # dwm.url = "github:Seeker0472/dwm/develop";
    dwm.url = "/home/seeker/Develop/dwm/";
    picom.url = "github:Seeker0472/picom";
    picom.inputs.nixpkgs.follows = "nixpkgs";
    dwm.inputs.nixpkgs.follows = "nixpkgs";

    # Home Manager
    home-manager = {
      # url = "github:nix-community/home-manager/release-24.05";
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    winapps = {
      url = "github:winapps-org/winapps/feat-nix-packaging";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };
  # function as value
  # an attribute set
  # 它是一个以 inputs 中的依赖项为参数的函数，函数的返回值是一个 attribute set，这个返回的 attribute set 即为该 flake 的构建结果
  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, nur, anyrun, dwm, winapps, picom, ... }@inputs:
    let
      system = "x86_64-linux";
      sharedConfig = import ./sharedConfig.nix;
      pkgs = import nixpkgs { inherit system; overlays = [ nur.overlays.default ]; };
    in
    {
      inherit system;
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs =  {inherit sharedConfig;};
        # TODO: nixpkgs/flake.nix 中找到 nixpkgs.lib.nixosSystem 的定义，跟踪它的源码，研究其实现方式。
        modules = [
          ./nixos
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [
              nur.overlays.default
              dwm.overlays.default
              picom.overlays.default
            ];
          }
          # home-manager as nixos module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.seeker = import users/seeker/home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
            home-manager.extraSpecialArgs = { inherit (inputs) winapps ; inherit sharedConfig; };
            home-manager.backupFileExtension = "backup";
          }
        ];
      };
    };
}
