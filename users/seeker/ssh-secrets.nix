{
  config,
  lib,
  osConfig,
  ...
}:
let
  deploySecrets = lib.attrByPath [ "machine" "secrets" "deploy" ] true osConfig;
  ageKeyPath = lib.attrByPath [ "machine" "secrets" "ageKeyPath" ] null osConfig;
in
lib.mkIf deploySecrets (
  lib.mkMerge [
    {
      programs.ssh.settings."*".IdentityFile = [ config.sops.secrets.id_ed25519.path ];

      sops.secrets = {
        id_ed25519 = {
          sopsFile = ./ssh.secrets.yaml;
          key = "ssh_id_ed25519_private_key";
          path = "${config.home.homeDirectory}/.ssh/id_seeker";
        };
        id_ed25519-public = {
          sopsFile = ./ssh.secrets.yaml;
          key = "ssh_id_ed25519_public_key";
          path = "${config.home.homeDirectory}/.ssh/id_seeker.pub";
        };
        nix_config = {
          sopsFile = ./ssh.secrets.yaml;
          key = "nix_config";
          path = "${config.home.homeDirectory}/.config/my_nix.conf";
        };
      };
    }
    (lib.mkIf (ageKeyPath != null) {
      sops.age.keyFile = ageKeyPath;
    })
  ]
)
