{ inputs, ... }:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./home.nix
    ./codex-secrets.nix
    ./nix-on-droid-ssh.nix
  ];
}
