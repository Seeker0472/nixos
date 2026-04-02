{
  config,
  lib,
  osConfig,
  ...
}:
let
  deploySecrets = lib.attrByPath [
    "machine"
    "secrets"
    "deploy"
  ] true osConfig;
in
{
  programs.ssh = {
    enable = true;
    # ProxyCommand nc -X connect -x 127.0.0.1:7890 %h %p
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        forwardAgent = true;
        addKeysToAgent = "yes";
        compression = false;
        serverAliveInterval = 30;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      }
      // lib.optionalAttrs deploySecrets {
        identityFile = [ config.sops.secrets."id_ed25519".path ];
      };
      "github.com" = {
        hostname = "ssh.github.com";
        port = 443;
        user = "git";
      };
      "ecos" = {
        hostname = "10.19.20.2";
        user = "seeker4721";
      };
    };
  };
}
// lib.optionalAttrs deploySecrets {
  # FIXME: add more keys-GPG machine specific key
  sops.secrets."id_ed25519" = {
    sopsFile = ./ssh.secrets.yaml;
    key = "ssh_id_ed25519_private_key";
    path = "${config.home.homeDirectory}/.ssh/id_seeker";
  };
  sops.secrets."id_ed25519-public" = {
    sopsFile = ./ssh.secrets.yaml;
    key = "ssh_id_ed25519_public_key";
    path = "${config.home.homeDirectory}/.ssh/id_seeker.pub";
  };
  sops.secrets."nix_config" = {
    sopsFile = ./ssh.secrets.yaml;
    key = "nix_config";
    path = "${config.home.homeDirectory}/.config/my_nix.conf";
  };
}
