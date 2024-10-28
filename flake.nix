###################################################################
#  flake's Entry File,
###################################################################
{
  # inputs 中的每一项依赖有许多类型与定义方式，可以是另一个 flake，也可以是一个普通的 Git 仓库，又或者一个本地路径。
  inputs = {
    # 定义了 nixpkgs 这一个依赖项，使用的是 flake 中最常见的引用方式，即github:owner/name/reference，这里的 reference 可以是分支名、commit-id 或 tag。

    # NixOS 官方软件源，这里使用 nixos-unstable 分支
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    nur.url = "github:nix-community/NUR";
    anyrun.url = "github:anyrun-org/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs";
    dwm.url = "github:Seeker0472/dwm/develop";
    dwm.inputs.nixpkgs.follows = "nixpkgs";

    # Home Manager
    home-manager = {
      # url = "github:nix-community/home-manager/release-24.05";
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    winapps = {
      url = "github:winapps-org/winapps/feat-nix-packaging";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  # function as value
  # an attribute set
  # 它是一个以 inputs 中的依赖项为参数的函数，函数的返回值是一个 attribute set，这个返回的 attribute set 即为该 flake 的构建结果
  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, nur, anyrun, dwm, winapps, ... }@inputs:
    let
      system = "x86_64-linux";
      # 添加NUR
      # TODO:HomeManager
      pkgs = import nixpkgs { inherit system; overlays = [ nur.overlay ]; };
    in
    {
      inherit system;
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        # TODO: nixpkgs/flake.nix 中找到 nixpkgs.lib.nixosSystem 的定义，跟踪它的源码，研究其实现方式。
        modules = [
          ./nixos
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [
              nur.overlay
              dwm.overlays.default
            ];
          }
            # {
            #   environment.systemPackages = [
            #     winapps.packages.${system}.winapps
            #     winapps.packages.${system}.winapps-launcher # optional
            #   ];
            # }
          # home-manager 配置为 nixos 的一个module, 在 nixos-rebuild switch 时，home-manager 配置也会被自动部署
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.seeker = import users/seeker/home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
            home-manager.extraSpecialArgs = inputs;
            # home-manager.backupFileExtension = "backup";  
          }
        ];
      };
    };
}
