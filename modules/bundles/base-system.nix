{ inputs, ... }:
{
  imports = [
    ../default.nix
    inputs.sops-nix.nixosModules.sops
    ../profiles/system/core/common.nix
    ../profiles/system/core/networking.nix
    ../profiles/system/core/openssh.nix
    ../profiles/secrets/sops.nix
    ../profiles/secrets/nix-config.nix
    ../profiles/secrets/webdav.nix
  ];
}
