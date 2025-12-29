{inputs, ...}: {
  imports = [inputs.home-manager.nixosModules.home-manager];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.seeker = import ./home.nix;

    # 将通用的 HM 模块
    sharedModules = [
      inputs.sops-nix.homeManagerModules.sops
      inputs.zen-browser.homeModules.beta
    ];
  };
}
