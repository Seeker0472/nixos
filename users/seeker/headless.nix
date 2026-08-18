{ inputs, ... }:
{
  imports = [
    ../home-manager.nix
  ];

  home-manager = {
    users.seeker = {
      imports = [
        inputs.sops-nix.homeManagerModules.sops
        ./home.nix
        ./ssh-secrets.nix
      ];
    };
  };
}
